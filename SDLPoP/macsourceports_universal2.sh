# game/app specific values
# SDLPoP's last tag (v1.24-RC, 2025) is a release candidate with fixes since,
# so this builds the latest code, versioned from the latest tag plus the date
# (e.g. 1.24-RC-20261126, see constants.sh)
export APP_VERSION=$(git -C ../../SDLPoP describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "1.24-RC")
export PRODUCT_NAME="SDLPoP"
export PROJECT_NAME="SDLPoP"
export PORT_NAME="SDLPoP"
export ICONSFILENAME="sdlpop"
export EXECUTABLE_NAME="prince"
export PKGINFO="APPLSPOP"

# constants
source ../common/constants.sh
source ../common/signing_values.local
# the /usr/local SDL2 and SDL2_image libraries are 11.0+
export MINIMUM_SYSTEM_VERSION="11.0"
export MACOSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION}

PATCH_DIR=$PWD

cd ../../${PROJECT_NAME}

# macOS changes -- see the patch. Settings, saves, screenshots, replays and
# mods live in ~/Library/Application Support/PrinceOfPersia, which is
# searched before the game data bundled in Contents/Resources.
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
rm -f ${EXECUTABLE_NAME}

# SDL2 and SDL2_image come from /usr/local. CMakeLists.txt puts the binary
# in the repo root. No build rpath: /usr/local/lib would win over the bundled Frameworks.
cmake -G Ninja -S src -B build-msp \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION} \
	-DSDL2=/usr/local \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-DCMAKE_SKIP_BUILD_RPATH=ON

cmake --build build-msp --parallel $NCPU || exit 1

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"
cp ${EXECUTABLE_NAME} "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

# the game data (it ships with the original DOS data), default settings,
# docs and the mods/replays readmes go in Resources
RESOURCES="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
for item in data doc mods replays; do
	ditto "${item}" "${RESOURCES}/${item}"
done
cp SDLPoP.ini README.md COPYING "${RESOURCES}"

# bundle the /usr/local libraries
cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
