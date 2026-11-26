# remc2 / Magic Carpet HD: the reverse engineered Magic Carpet 2: The
# Netherworlds, and (remc1) Magic Carpet and Hidden Worlds
# (https://github.com/turican0/remc2, developed further as
# https://github.com/thobbsinteractive/magic-carpet-2-hd).
#
# One app for the three games: it opens remc2's launcher (remc2-configurator),
# with a Play button for each game whose files are there, and its settings.
# The launcher starts the game (remc2, next to it in Contents/MacOS) with
# --game mc1, mc1hw or mc2.

# game/app specific values
# Releases are tagged like 0.9.18.0-alpha-looking-glass; a release build
# passes the tag as $2. Builds of the latest code add the date (constants.sh).
export APP_VERSION="0.9.18.0"
export PRODUCT_NAME="remc2"
# the MSPBuildSystem folder and the source checkout (../../remc2)
export PROJECT_NAME="remc2"
export PORT_NAME="remc2"
export ICONSFILENAME="remc2"
# the launcher; the game is remc2
export EXECUTABLE_NAME="remc2-configurator"
export PKGINFO="APPLREM2"

# constants
source ../common/constants.sh
source ../common/signing_values.local
# the /usr/local libraries it links against (SDL2, wxWidgets etc.) are 11.0+. The Vulkan
# SDK's MoltenVK is 12.0+; on 11 the game can't load it and uses its
# software renderer instead.
export MINIMUM_SYSTEM_VERSION="11.0"
export MACOSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION}
export BUNDLE_ID="com.macsourceports.remc2"

# header-only libraries remc2 expects in its source folder on Linux and macOS
SPDLOG_TAG="v1.15.3"
NLOHMANN_JSON_TAG="v3.12.0"

PATCH_DIR=$PWD

cd ../../${PROJECT_NAME}

git submodule update --init --recursive

# macOS changes -- see the patch (remc2/portability/msp_macos.h has the
# details). The files the game ships with (config.json, fonts, shaders, the
# launcher's pictures, the enhanced assets) are in the app's Resources. The
# original games go in ~/Library/Application Support: Magic Carpet 2's GOG
# GAME folder, game.gog and game.ins in MagicCarpet2, Magic Carpet Plus's
# CARPET.CD folder in MagicCarpet. The launcher extracts the CD images there
# (to CD_Files; Magic Carpet 2's audio tracks, the speech, to CD_Files/SPEECH)
# and says where the files go when no game has them. config.json (copied from
# the app's one) and the log are in MagicCarpet2, the saves in the games'
# folders. Also makes the Vulkan renderer work (SDL's Metal renderer was
# remaking the Vulkan window without Vulkan), and the editor and configurator
# optional. Skip if it's already applied.
if ! git apply -R --check "${PATCH_DIR}/msp-macos.patch" 2>/dev/null; then
	git apply --3way "${PATCH_DIR}/msp-macos.patch"
fi

if [ -n "$2" ]; then
	# 0.9.18.0-alpha-looking-glass -> 0.9.18.0
	APP_VERSION="${2#v}"
	export APP_VERSION="${APP_VERSION%%-*}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}
rm -rf build-msp

# spdlog and nlohmann-json, where remc2's CMakeLists.txt looks for them
rm -rf spdlog nlohmann-json msp-nlohmann-json
git clone --depth 1 --branch ${SPDLOG_TAG} https://github.com/gabime/spdlog.git spdlog
git clone --depth 1 --branch ${NLOHMANN_JSON_TAG} https://github.com/nlohmann/json.git msp-nlohmann-json
mkdir -p nlohmann-json
cp -R msp-nlohmann-json/single_include/nlohmann nlohmann-json/
rm -rf msp-nlohmann-json

# the Vulkan loader, headers and glslc (for the shaders)
source ~/VulkanSDK/${VULKAN_SDK_VERSION}/setup-env.sh

# SDL2, SDL2_mixer, SDL2_ttf, SDL2_image, libpng and fmt are universal in
# /usr/local; vk-bootstrap and VulkanMemoryAllocator are fetched by CMake.
# wxWidgets (for the launcher) is universal in /usr/local too. The editor
# isn't built.
cmake -G Ninja -B build-msp \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION} \
	-DCMAKE_PREFIX_PATH=/usr/local \
	-DREMC2_BUILD_TOOLS=ON \
	.

cmake --build build-msp --target remc2 remc2-configurator --parallel $NCPU

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"
cp build-msp/remc2-configurator/remc2-configurator "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
cp build-msp/remc2/remc2 "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/remc2"

# what remc2's install() puts next to the executable goes in Resources, where
# the patch looks for it
RESOURCES="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
cp config.json "${RESOURCES}"
mkdir -p "${RESOURCES}/font"
cp remc2/font/16x16-font.bmp remc2/font/8x8-font.bmp remc2/font/UbuntuMono-B.ttf "${RESOURCES}/font"
ditto build-msp/remc2/shaders "${RESOURCES}/shaders"
ditto remc2-configurator/images "${RESOURCES}/images"
mkdir -p "${RESOURCES}/MC2"
for dir in music-ogg awe32data graphics; do
	ditto enhancedassets/MC2/${dir} "${RESOURCES}/MC2/${dir}"
done
cp README.md "${RESOURCES}"

# MoltenVK, found by the Vulkan loader through the ICD in Resources
mkdir -p "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
cp "${VULKAN_SDK}/lib/libMoltenVK.dylib" "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "${RESOURCES}/vulkan/icd.d"
cp "${PATCH_DIR}/MoltenVK_icd.json" "${RESOURCES}/vulkan/icd.d"

# bundle the /usr/local libraries, and the Vulkan loader from the SDK
cd ${BUILT_PRODUCTS_DIR}
for exe in remc2 ${EXECUTABLE_NAME}; do
	"../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/${exe}" "${FRAMEWORKS_FOLDER_PATH}" "${VULKAN_SDK}/"
	# the build rpath into the SDK, which copy_dependencies.sh only strips
	# when it's under /usr/local
	for rpath in $(otool -l "${EXECUTABLE_FOLDER_PATH}/${exe}" | awk '/cmd LC_RPATH/{getline; getline; print $2}' | sort -u); do
		if [[ "$rpath" == /* ]]; then
			install_name_tool -delete_rpath "$rpath" "${EXECUTABLE_FOLDER_PATH}/${exe}"
		fi
	done
done
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
