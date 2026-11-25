# game/app specific values
# OpenFodder's last release (2.0.0, 2025) predates its move to SDL3, so this
# builds the latest code, versioned from the latest tag plus the date (e.g.
# 2.0.0-20261124, see constants.sh)
export APP_VERSION=$(git -C ../../openfodder describe --tags --abbrev=0 2>/dev/null || echo "2.0.0")
export PRODUCT_NAME="OpenFodder"
export PROJECT_NAME="openfodder"
export PORT_NAME="OpenFodder"
export ICONSFILENAME="openfodder"
export EXECUTABLE_NAME="openfodder"
export PKGINFO="APPLOFOD"

# constants
source ../common/constants.sh
source ../common/signing_values.local
# the /usr/local libraries it links against (SDL3 etc.) are 11.0+
export MINIMUM_SYSTEM_VERSION="11.0"
export MACOSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION}

# pkg-config (for FFmpeg) comes from /usr/local
export PATH="/usr/local/bin:$PATH"

PATCH_DIR=$PWD

cd ../../${PROJECT_NAME}

# the game's data repo (campaigns, scripts, demos) is the Run submodule
git submodule update --init --recursive

# macOS changes -- see the patch. Launched from the app bundle, the game
# uses ~/Library/Application Support/OpenFodder as its working directory
# (INI, saves, and the retail data in Data/Dos_CD and Data/Dos2_CD), then
# falls back on the data bundled in Contents/Resources.
# Skip if it's already applied.
if ! git apply -R --check "${PATCH_DIR}/msp-macos.patch" 2>/dev/null; then
	git apply "${PATCH_DIR}/msp-macos.patch"
fi

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}
rm -rf build-msp

# no vcpkg: SDL3, SDL3_mixer, curl and FFmpeg (intro videos) come from
# /usr/local. GGPO, libsodium and the CAPS image SDK are fetched by CMake.
# No build rpath: /usr/local/lib would win over the bundled Frameworks.
cmake -G Ninja -B build-msp \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION} \
	-DCMAKE_PREFIX_PATH=/usr/local \
	-DCMAKE_SKIP_BUILD_RPATH=ON \
	.

cmake --build build-msp --parallel $NCPU

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"
cp build-msp/${EXECUTABLE_NAME} "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

# the data repo (campaigns, scripts, demo data, about.png) goes in Resources,
# which the game searches after the user's Application Support folder
RESOURCES="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
for item in Campaigns Data Scripts about.png; do
	ditto "Run/${item}" "${RESOURCES}/${item}"
done
cp openfodder.ini.example COPYING "${RESOURCES}"

# bundle the /usr/local libraries
cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
