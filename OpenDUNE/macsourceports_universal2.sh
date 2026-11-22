# game/app specific values
# OpenDUNE's last tagged release is 0.9 (2016); dated builds of the latest
# code become 0.9-20261121 (see constants.sh)
export APP_VERSION="0.9"
export PRODUCT_NAME="OpenDUNE"
export PROJECT_NAME="OpenDUNE"
export PORT_NAME="OpenDUNE"
export ICONSFILENAME="OpenDUNE"
export EXECUTABLE_NAME="opendune"
export PKGINFO="APPLODUN"

# constants
source ../common/constants.sh
source ../common/signing_values.local
# the /usr/local SDL2 it links against is 11.0+
export MINIMUM_SYSTEM_VERSION="11.0"
export MACOSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION}

PATCH_DIR=$PWD

cd ../../${PROJECT_NAME}

# macOS changes: use ~/Library/Application Support/Dune2 (shared with other
# Dune II ports) rather than .../OpenDUNE, fall back to its data folder
# whenever the bundle has no game data (and create that folder), and say
# where the data goes when it's missing. Also fixes the SDL2 renderer's
# garbage on Metal (upstream issue #406 / PR #408, plus write-only texture
# locks) and makes the window resizable -- see the patch.
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

# OpenDUNE's own (OpenTTD-style) configure. Both architectures in one pass:
# the universal SDL2 in /usr/local covers both. Its --enable-universal and
# static options are for the old PPC/i386 days, so they're off. Munt is off
# since a libmt32emu.a in /usr/local gets detected but its MIDI glue needs
# OSS (sys/soundcard.h); music goes through CoreAudio's DLS synth instead.
# SDL2_image only sets the window icon from a PNG (which macOS ignores; the
# Dock uses the bundle's icon), yet bundling it pulls in ~30 image codec
# libraries. It's detected only through pkg-config, so hiding pkg-config's
# search path leaves it out (SDL2 itself comes from sdl2-config).
make distclean >/dev/null 2>&1 || true
PKG_CONFIG_LIBDIR=/nonexistent \
CC="clang -arch arm64 -arch x86_64" \
CFLAGS="-O2" \
./configure \
	--disable-static \
	--with-sdl2=/usr/local/bin/sdl2-config \
	--without-sdl \
	--without-munt \
	--without-osx-sysroot

make -j$NCPU

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"
cp bin/${EXECUTABLE_NAME} "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

# the sample ini documents the options (opendune.ini goes in
# ~/Library/Application Support/Dune2)
cp bin/opendune.ini.sample "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/"

# bundle the /usr/local libraries
cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
