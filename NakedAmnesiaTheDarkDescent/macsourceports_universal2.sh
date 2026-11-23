# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="NakedAmnesiaTheDarkDescent"
export PROJECT_NAME="NakedAmnesiaTheDarkDescent"
export PORT_NAME="NakedAmnesiaTheDarkDescent"
export ICONSFILENAME="nakedamnesiathedarkdescent"
export EXECUTABLE_NAME="Amnesia"
export PKGINFO="APPLATDD"

# constants
source ../common/constants.sh
source ../common/signing_values.local
# the /usr/local libraries it links against (SDL2 etc.) are 11.0+
export MINIMUM_SYSTEM_VERSION="11.0"
export MACOSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION}

PATCH_DIR=$PWD

cd ../../${PROJECT_NAME}

# macOS support -- see the patch. Upstream only builds on Windows (Visual
# Studio, prebuilt libraries); its CMake files are Frictional Games' 2013
# ones, for prebuilt Mac/Linux libraries that aren't in the repository.
#  - CMake: AngelScript, Newton and the OpenAL wrapper built from the
#    bundled sources, everything else from /usr/local (the bundled 2010
#    headers kept out of the way); no FBX loader (Autodesk's FBX SDK 2012),
#    launcher or bundle step
#  - Apple silicon: native AngelScript calls on arm64 (as_callfunc_arm64.cpp,
#    AngelScript 2.19 only knows x86/x64), and Newton's scalar math in place
#    of its SSE code
#  - the game data (the Windows/Linux game folder, with resources.cfg) is
#    looked for in ~/Library/Application Support/Amnesia The Dark Descent,
#    then beside the app, with an alert if it isn't found. Saves and settings
#    stay in ~/Library/Application Support/Frictional Games/Amnesia, where the
#    original Mac release keeps them.
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

# No build rpath (/usr/local/lib), so the app loads the libraries bundled in
# Contents/Frameworks. The system OpenAL framework has no EFX, so use OpenAL
# Soft from /usr/local.
rm -rf build-msp
cmake -S amnesia/src -B build-msp \
	-Wno-dev \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION} \
	-DCMAKE_PREFIX_PATH=/usr/local \
	-DCMAKE_SKIP_BUILD_RPATH=ON \
	-DOPENAL_LIBRARY=/usr/local/lib/libopenal.dylib \
	-DOPENAL_INCLUDE_DIR=/usr/local/include/AL
cmake --build build-msp --parallel $NCPU || exit 1

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"
cp build-msp/Amnesia "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

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
