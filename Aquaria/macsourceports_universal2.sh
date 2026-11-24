# game/app specific values
# Aquaria OSE's only tagged releases are from 2015 (OSE-v1.002), so this is
# built from the latest code: dated builds are just the date (20261123, see
# constants.sh); a build without one is still called 1.0
if [ -n "${MSP_VERSION_DATE}" ]; then
	export APP_VERSION=""
else
	export APP_VERSION="1.0"
fi
export PRODUCT_NAME="Aquaria"
export PROJECT_NAME="Aquaria"
export PORT_NAME="Aquaria"
export ICONSFILENAME="aquaria"
export EXECUTABLE_NAME="aquaria"
export PKGINFO="APPLAQUA"

# constants
source ../common/constants.sh
source ../common/signing_values.local
# the /usr/local libraries it links against (SDL2, OpenAL Soft) are 11.0+
export MINIMUM_SYSTEM_VERSION="11.0"
export MACOSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION}

PATCH_DIR=$PWD

cd ../../${PROJECT_NAME}

# macOS support -- see the patch:
#  - the original game's data (from the GOG/Humble/Steam version: data, gfx,
#    mus, sfx, vox, ...) is looked for in ~/Library/Application Support/Aquaria
#    (where saves and settings already go), or $AQUARIA_DATA_PATH, with an
#    alert if it isn't there
#  - the repo's updated data files ("files", which upstream has you copy over
#    the game's) are bundled in Contents/Resources/files and used on top of
#    the game's data, so the user's copy of the game stays untouched
#  - the updated default mod scripts (game_scripts/_mods) are bundled in
#    Contents/Resources/files/_mods and copied over the user's _mods on launch
#  - the bundled 2009 libpng's classic Mac OS <fp.h> include
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

# SDL2 and OpenAL Soft from /usr/local; Lua, Ogg/Vorbis, zlib, libpng,
# FreeType and FTGL are the bundled copies. No build rpath (/usr/local/lib),
# so the app loads the libraries bundled in Contents/Frameworks.
rm -rf build-msp
cmake -S . -B build-msp \
	-Wno-dev \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION} \
	-DCMAKE_PREFIX_PATH=/usr/local \
	-DCMAKE_SKIP_BUILD_RPATH=ON \
	-DAQUARIA_USE_SDL2=ON \
	-DOPENAL_LIBRARY=/usr/local/lib/libopenal.dylib \
	-DOPENAL_INCLUDE_DIR=/usr/local/include/AL
cmake --build build-msp --parallel $NCPU || exit 1

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"
cp build-msp/aquaria "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

# the updated data files and mod scripts, used on top of the original game's
RESOURCES="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
ditto files "${RESOURCES}/files"
ditto game_scripts/_mods "${RESOURCES}/files/_mods"

# bundle the /usr/local libraries
cd "${BUILT_PRODUCTS_DIR}"
mkdir -p "${FRAMEWORKS_FOLDER_PATH}"
"../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${FRAMEWORKS_FOLDER_PATH}"
# copy_dependencies skips libraries it can't find in /usr/local/lib, which
# would give an app that dies at launch. Stop here instead.
for lib in $(otool -L "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${FRAMEWORKS_FOLDER_PATH}"/*.dylib | grep -o '@rpath/[^ ]*' | sort -u); do
	if [ ! -e "${FRAMEWORKS_FOLDER_PATH}/${lib#@rpath/}" ]; then
		echo "Error: ${lib#@rpath/} is not in the bundle (is it installed in /usr/local/lib?)"
		exit 1
	fi
done
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
