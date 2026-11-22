# game/app specific values
# gameflorist/dunedynasty, the maintained continuation of the SourceForge
# project (whose last release was 1.5.7 in 2013). Its last release is v1.6.4;
# dated builds of the latest code become 1.6.4-20261121 (see constants.sh)
export APP_VERSION="1.6.4"
export PRODUCT_NAME="Dune Dynasty"
export PROJECT_NAME="dunedynasty"
export PORT_NAME="Dune Dynasty"
export ICONSFILENAME="dunedynasty"
export EXECUTABLE_NAME="dunedynasty"
export PKGINFO="APPLDUND"

# constants
source ../common/constants.sh
source ../common/signing_values.local
# the /usr/local libraries it links against (Allegro 5 etc.) are 11.0+
export MINIMUM_SYSTEM_VERSION="11.0"
export MACOSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION}
export BUNDLE_ID="com.macsourceports.dunedynasty"
# as upstream's bundle: the game sizes its own UI for the display
export HIGH_RESOLUTION_CAPABLE="false"
# (fullscreen stays below a MacBook's camera notch thanks to the patch in
# libraries/allegro5.sh)

PATCH_DIR=$PWD

cd ../../${PROJECT_NAME}

# macOS changes: also look for the Dune II data in ~/Library/Application
# Support/Dune2/data (shared with the other Dune II ports, e.g. OpenDUNE),
# creating it and naming it when the data is missing, and show errors in an
# alert, since an app started from the Finder has no terminal -- see the
# patch. Skip if it's already applied.
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

# CMAKE_MACOSX_BUNDLE lays out the game's own data (campaign, gfx, music) in
# the bundle Resources the way the game expects; we take the executable and
# those into our own bundle. No build rpath (/usr/local/lib), so the app loads
# the libraries bundled in Contents/Frameworks. No FluidSynth: it's only an
# extra music set that needs a soundfont the player supplies, and would bring
# glib, libsndfile and portaudio along -- the default music (AdLib emulation,
# General MIDI through macOS's own synth) doesn't need it.
rm -rf build-msp
mkdir build-msp
cd build-msp
cmake .. \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_MACOSX_BUNDLE=YES \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION} \
	-DCMAKE_SKIP_BUILD_RPATH=ON \
	-DWITH_FLUIDSYNTH=OFF
cmake --build . --parallel $NCPU
cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"
cp build-msp/dist/dunedynasty.app/Contents/MacOS/${EXECUTABLE_NAME} "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
RESOURCES="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
for folder in campaign data gfx music; do
	ditto build-msp/dist/dunedynasty.app/Contents/Resources/${folder} "${RESOURCES}/${folder}"
done
cp static/general/dunedynasty.cfg-sample "${RESOURCES}/"

# bundle the /usr/local libraries
cd "${BUILT_PRODUCTS_DIR}"
mkdir -p "${FRAMEWORKS_FOLDER_PATH}"
"../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${FRAMEWORKS_FOLDER_PATH}"
# copy_dependencies only finds libraries in /usr/local/lib and skips any it
# can't find, so a missing one (e.g. Allegro before libraries/allegro5.sh has
# run) would give an app that dies at launch. Stop here instead.
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
