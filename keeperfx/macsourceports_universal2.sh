# game/app specific values
# KeeperFX's last stable release (1.4.0) predates its Linux/CMake support,
# which the macOS build builds on, so this builds the latest code. It's
# versioned like KeeperFX's own Alpha builds, 1.4.0.<commit count>, plus the
# date (e.g. 1.4.0.5625-20261120, see constants.sh)
KFX_VERSION_MK=../../keeperfx/version.mk
export APP_VERSION="$(sed -n 's/^VER_MAJOR=//p' ${KFX_VERSION_MK}).$(sed -n 's/^VER_MINOR=//p' ${KFX_VERSION_MK}).$(sed -n 's/^VER_RELEASE=//p' ${KFX_VERSION_MK}).$(git -C ../../keeperfx rev-list --count HEAD)"
export PRODUCT_NAME="KeeperFX"
export PROJECT_NAME="keeperfx"
export PORT_NAME="KeeperFX"
export ICONSFILENAME="keeperfx"
export EXECUTABLE_NAME="KeeperFX"
export PKGINFO="APPLKPFX"

# constants
source ../common/constants.sh
source ../common/signing_values.local
# C++20 (std::filesystem etc.) and the /usr/local libraries need 11.0
export MINIMUM_SYSTEM_VERSION="11.0"
export MACOSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION}
# LuaJIT compiles Lua scripts to machine code at runtime
export ENTITLEMENTS_FILE="../MSPBuildSystem/keeperfx/keeperfx.entitlements"

# pkg-config comes from /usr/local
export PATH="/usr/local/bin:$PATH"

PATCH_DIR=$PWD

cd ../../${PROJECT_NAME}

# macOS changes -- see the patch:
# - CMake: macOS as a platform, sharing the Linux (POSIX) platform layer;
#   dependencies from /usr/local; astronomy and centijson built from source
# - the game folder is ~/Library/Application Support/KeeperFX: KeeperFX's own
#   data is linked in from the app bundle and the original Dungeon Keeper
#   files are copied in from the player's copy of the game (MacAppSupport.cpp)
# - OpenGL renderer: no deadlock between the render thread's swap and the
#   main thread, and the window framebuffer bound for the swap (was black)
# - Mach-O section names for the replay rewind data, crash handler context,
#   strnicmp and iconv
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

# SDL3 (+ image, mixer), FFmpeg, OpenAL, LuaJIT, libspng, minizip, zlib,
# ENet6, libcurl, miniupnpc and libnatpmp come from /usr/local (see
# libraries/). BUILD_NUMBER is the commit count, as in KeeperFX's own builds.
cmake -G Ninja -B build-msp \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION} \
	-DCMAKE_PREFIX_PATH=/usr/local \
	-DBUILD_NUMBER=$(git rev-list --count HEAD) \
	.

cmake --build build-msp --target keeperfx --parallel $NCPU

mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp build-msp/keeperfx "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

# create the app bundle (Info.plist and icon)
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

# KeeperFX's own game data (graphics, campaigns, maps, configs) -- the latest
# complete release with the latest Alpha patch on top, see assemble_data.sh.
# Downloads are cached in MSPBuildSystem/keeperfx/data-cache.
"${PATCH_DIR}/assemble_data.sh" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/keeperfx" "${PATCH_DIR}/data-cache"

# bundle the /usr/local libraries
cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" "entitlements"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
