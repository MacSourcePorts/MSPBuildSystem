# game/app specific values
# Descent3 hasn't tagged a release since v1.5.0 (2024), so this builds the
# latest code, versioned from its CMakeLists.txt plus the date (e.g.
# 1.6.0-20261120, see constants.sh)
export APP_VERSION=$(sed -n 's/^[[:space:]]*VERSION[[:space:]]*\([0-9.]*\).*/\1/p' ../../Descent3/CMakeLists.txt | head -n1)
export PRODUCT_NAME="Descent3"
export PROJECT_NAME="Descent3"
export PORT_NAME="Descent 3"
export ICONSFILENAME="Descent3"
export EXECUTABLE_NAME="Descent3"
export PKGINFO="APPLDSC3"

# constants
source ../common/constants.sh
source ../common/signing_values.local
# the /usr/local libraries it links against (theora etc.) are 11.0+
export MINIMUM_SYSTEM_VERSION="11.0"
export MACOSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION}

# pkg-config (for theora/vorbis/ogg) comes from /usr/local
export PATH="/usr/local/bin:$PATH"

PATCH_DIR=$PWD

cd ../../${PROJECT_NAME}

# macOS changes -- see the patch:
# - Ogg Theora movie playback, for the Steam release's .ogv movies
# - also look for game data where Steam for Mac installs it
# - a missing #include that newer libc++ needs
# - camera shake (e.g. kicking in the afterburner) converted negative floats
#   straight to unsigned angles, which on Apple Silicon garbled the view and
#   made the cockpit text jump around
# - mouse wheel weapon cycling counts whole wheel ticks, not every trackpad/
#   Magic Mouse scroll event
# - the menu cursor moves with the mouse one-to-one (its speed depended on
#   mouse events per frame, so it crawled on the main menu)
# - no duplicate entries in the multiplayer service list
# - signing identities with parentheses in them (CODESIGN_IDENTITY below)
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

# no vcpkg: SDL3, glm, zlib, plog and cpp-httplib come from /usr/local (see
# libraries/plog.sh and libraries/cpp-httplib.sh). CODESIGN_IDENTITY signs the
# level scripts and online modules before they're packed into hog files --
# they're extracted and loaded at runtime, so they need our team's signature.
cmake -G Ninja -B build-msp \
	-DCMAKE_BUILD_TYPE=Release \
	-DUSE_VCPKG=OFF \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION} \
	-DCMAKE_PREFIX_PATH=/usr/local \
	-DCODESIGN_IDENTITY="${SIGNING_IDENTITY}" \
	.

cmake --build build-msp --parallel $NCPU

mkdir -p ${BUILT_PRODUCTS_DIR}
ditto build-msp/build/${WRAPPER_NAME} "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"

# create the app bundle (Info.plist and icon)
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

# The game looks for its files in Contents/Resources (SDL's base path) ahead
# of the user's data in ~/Library/Application Support/Outrage Entertainment/
# Descent 3, so ours win over any older copies there: the level scripts
# (d3-osx.hog), the multiplayer services (online) and game types (netgames)
RESOURCES="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
cp build-msp/build/d3-osx.hog "${RESOURCES}"
ditto build-msp/build/online "${RESOURCES}/online"
mv "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/netgames" "${RESOURCES}/netgames"

# bundle the /usr/local libraries
cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

# codesign --deep doesn't reach code in Resources, so sign the game types here
for module in "${RESOURCES}"/netgames/*.d3m; do
	codesign --force --options runtime --timestamp --sign "${SIGNING_IDENTITY}" "$module"
done

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
