# game/app specific values
export APP_VERSION="4.0.2"
export PRODUCT_NAME="Maelstrom"
export PROJECT_NAME="Maelstrom"
export PORT_NAME="Maelstrom"
export ICONSFILENAME="Maelstrom"
export EXECUTABLE_NAME="Maelstrom"
export PKGINFO="APPLMLST"

# constants
source ../common/constants.sh
# upstream's own macOS build targets 11.0
export MINIMUM_SYSTEM_VERSION="11.0"

cd ../../${PROJECT_NAME}

# the tag is release-4.0.2
if [ -n "$2" ]; then
	export APP_VERSION="${2/release-/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at: $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}
rm -rf build-macos
rm -rf install-macos

# Upstream's CMake build, as its CI does it: one universal pass, with the
# vendored SDL3, SDL3_net and PhysFS submodules. Steam support is off -- it
# would need Valve's libsteam_api in the bundle and Steam running.
cmake -B build-macos \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION} \
	-DCMAKE_INSTALL_PREFIX="$PWD/install-macos" \
	-DSTEAM=OFF \
	|| exit 1
cmake --build build-macos --config Release --parallel $NCPU || exit 1
# a standalone install: Maelstrom, its libraries, Data and mods in one folder
cmake --install build-macos --config Release || exit 1

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

mkdir -p "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
cp install-macos/${EXECUTABLE_NAME} "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" || exit 1
cp -a install-macos/*.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}" || exit 1
# the install looks for its libraries next to the executable
install_name_tool -add_rpath @executable_path/../Frameworks "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" || exit 1

# SDL_GetBasePath() is Contents/Resources in a bundle, where the game looks
# for Data (and mods next to it)
cp -R install-macos/Data install-macos/mods "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" || exit 1

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
