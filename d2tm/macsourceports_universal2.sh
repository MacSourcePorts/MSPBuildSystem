# game/app specific values
# D2TM's last tagged release is v0.8.5, but development is far past it
# (upstream publishes "bleeding edge" builds several times a day); dated
# builds of the latest code become 0.8.5-20261121 (see constants.sh)
export APP_VERSION="0.8.5"
export PRODUCT_NAME="Dune II - The Maker"
# the MSPBuildSystem folder; the source checkout is ../../Dune-II---The-Maker
export PROJECT_NAME="d2tm"
export PORT_NAME="Dune II - The Maker"
export ICONSFILENAME="d2tm"
export EXECUTABLE_NAME="d2tm"
export PKGINFO="APPLD2TM"

# constants
source ../common/constants.sh
source ../common/signing_values.local
# C++23 std::format needs the floating point to_chars in the macOS 13.3
# libc++ (as with PvZ-Portable and SkinDeep)
export MINIMUM_SYSTEM_VERSION="13.3"
export MACOSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION}
export BUNDLE_ID="com.macsourceports.d2tm"

PATCH_DIR=$PWD

cd ../../Dune-II---The-Maker

# macOS changes: in an app bundle, run from Contents/Resources (the game reads
# its data relative to the working directory) and write the log, saved
# skirmish maps and custom music folders to the user data directory it
# already uses for preferences (~/Library/Application Support/D2TM/Dune II -
# The Maker), loading the saved options at startup, and use the bundled
# soundfont for the MIDI music. Also makes the unit tests optional, as they
# need Catch2 -- see the patch.
# Skip if it's already applied.
# Upstream changes many times a day, so apply it as a three-way merge: code
# that has moved, or changed near our edits, merges like a branch would, and
# only a real conflict (upstream rewrote the same lines) stops the build, which
# then needs the patch updated.
if ! git apply -R --check "${PATCH_DIR}/msp-macos.patch" 2>/dev/null; then
	git apply --3way "${PATCH_DIR}/msp-macos.patch"
fi

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}

# the version shown in game and in its log: upstream's own build label, e.g.
# bleeding-edge-a3057c90 (it tags every build), else v0.8.5-736-ga3057c90
export ENV_D2TM_VERSION="$(git describe --tags --always)"

rm -rf build-msp
mkdir build-msp
cd build-msp
# no build rpath (/usr/local/lib): the app must load the libraries bundled in
# Contents/Frameworks, even on a Mac that has others in /usr/local/lib
cmake .. \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION} \
	-DCMAKE_SKIP_BUILD_RPATH=ON \
	-DD2TM_TESTS=OFF
cmake --build . --parallel $NCPU
cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"
cp build-msp/${EXECUTABLE_NAME} "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

# the game data, laid out as upstream's create_release.sh lays out bin/
RESOURCES="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
ditto resources/bin/campaign "${RESOURCES}/campaign"
ditto resources/bin/data "${RESOURCES}/data"
ditto resources/bin/skirmish "${RESOURCES}/skirmish"
# Fullscreen (which the window's green button enters) fills the screen
# (Letterbox) instead of only scaling by whole numbers (IntegerScale), which on
# most Mac screens leaves the game at 1x in the middle. Alt+L switches it in
# game, and the choice is saved.
sed 's/^ScalingMode=IntegerScale$/ScalingMode=Letterbox/' resources/bin/settings.ini > "${RESOURCES}/settings.ini"
grep -q '^ScalingMode=Letterbox$' "${RESOURCES}/settings.ini"
# the game rules (houses, units, upgrades, particles...): every
# resources/*.ini.org, as create_release.sh copies them, so new ones come along
for rules in resources/*.ini.org; do
	name=$(basename "$rules" .ini.org)
	cp "$rules" "${RESOURCES}/${name}.ini"
done
cp resources/doc/versionhistory.txt resources/doc/controls.txt "${RESOURCES}/"

# The music is MIDI, played by FluidSynth, which needs a General MIDI
# soundfont: GeneralUser GS (free to bundle, see its LICENSE.txt), pinned to a
# commit and cached in MSPBuildSystem/d2tm/soundfont-cache. The
# game uses it unless SDL_SOUNDFONTS names another (see the patch).
SOUNDFONT_COMMIT="684543d5e5efaef08d02be50dcda8d552478fa60"
SOUNDFONT_CACHE="${PATCH_DIR}/soundfont-cache/${SOUNDFONT_COMMIT}"
SOUNDFONT_URL="https://raw.githubusercontent.com/mrbumpy409/GeneralUser-GS/${SOUNDFONT_COMMIT}"
mkdir -p "${SOUNDFONT_CACHE}"
if [ ! -f "${SOUNDFONT_CACHE}/GeneralUser-GS.sf2" ]; then
	curl -fL -o "${SOUNDFONT_CACHE}/GeneralUser-GS.sf2.part" "${SOUNDFONT_URL}/GeneralUser-GS.sf2"
	mv "${SOUNDFONT_CACHE}/GeneralUser-GS.sf2.part" "${SOUNDFONT_CACHE}/GeneralUser-GS.sf2"
fi
if [ ! -f "${SOUNDFONT_CACHE}/LICENSE.txt" ]; then
	curl -fL -o "${SOUNDFONT_CACHE}/LICENSE.txt" "${SOUNDFONT_URL}/documentation/LICENSE.txt"
fi
cp "${SOUNDFONT_CACHE}/GeneralUser-GS.sf2" "${RESOURCES}/"
cp "${SOUNDFONT_CACHE}/LICENSE.txt" "${RESOURCES}/GeneralUser-GS-LICENSE.txt"

# bundle the /usr/local libraries
cd ${BUILT_PRODUCTS_DIR}
mkdir -p "${FRAMEWORKS_FOLDER_PATH}"
"../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${FRAMEWORKS_FOLDER_PATH}"
# SDL3_mixer loads FluidSynth at run time (dlopen, see libraries/sdl3_mixer.sh),
# so it isn't linked and copy_dependencies can't see it: copy it and the
# libraries it links against by hand
cp -L /usr/local/lib/libfluidsynth.3.dylib "${FRAMEWORKS_FOLDER_PATH}/"
chmod u+w "${FRAMEWORKS_FOLDER_PATH}/libfluidsynth.3.dylib"
"../../MSPBuildSystem/common/copy_dependencies.sh" "${FRAMEWORKS_FOLDER_PATH}/libfluidsynth.3.dylib" "${FRAMEWORKS_FOLDER_PATH}"
# some of them (glib) carry an rpath of /usr/local/lib from their own builds,
# which would load their dependencies from there instead of from the bundle
for lib in "${FRAMEWORKS_FOLDER_PATH}"/*.dylib; do
	[ -L "$lib" ] && continue
	if otool -l "$lib" | grep -A2 LC_RPATH | grep -q 'path /usr/local/lib '; then
		chmod u+w "$lib"
		install_name_tool -delete_rpath /usr/local/lib "$lib"
	fi
done
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
