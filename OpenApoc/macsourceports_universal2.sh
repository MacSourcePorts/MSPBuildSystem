# game/app specific values
# OpenApoc tags its (pre-)releases by date (e.g. 20260916); Buildbot passes
# the tag it built as $2
export APP_VERSION=$(git -C ../../OpenApoc describe --tags --abbrev=0 2>/dev/null || echo "1.0")
export PRODUCT_NAME="OpenApoc"
export PROJECT_NAME="OpenApoc"
export PORT_NAME="OpenApoc"
export ICONSFILENAME="openapoc"
export EXECUTABLE_NAME="OpenApoc"
export PKGINFO="APPLOAPC"

# constants
source ../common/constants.sh
source ../common/signing_values.local
# the /usr/local libraries it links against (SDL2, Boost etc.) are 11.0+
export MINIMUM_SYSTEM_VERSION="11.0"
export MACOSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION}

export PATH="/usr/local/bin:$PATH"

PATCH_DIR=$PWD

cd ../../${PROJECT_NAME}

git submodule update --init --recursive

# macOS changes -- see the patch. The X-COM: Apocalypse CD image (cd.iso, or
# GOG's XCOM.cue + XCOM.BIN) and saved games go in
# ~/Library/Application Support/OpenApoc, next to settings.conf and log.txt;
# the game tells the player where if it can't find them.
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

# The build runs OpenApoc's data extractor on a CD image to make the base
# game state (data/mods/base/base_gamestate) that ships with the game. Use
# the minimal image OpenApoc's own CI uses (see appveyor.yml), cached
# outside the checkout since Buildbot cleans untracked files.
CD_CACHE="${HOME}/Library/Caches/MSPBuildSystem/OpenApoc"
CD_PATH="${CD_CACHE}/cd_minimal.iso"
if [ ! -f "${CD_PATH}" ]; then
	mkdir -p "${CD_CACHE}"
	curl -fL -o "${CD_PATH}.xz" http://s2.jonnyh.net/pub/cd_minimal.iso.xz
	xz -d "${CD_PATH}.xz"
fi

rm -rf ${BUILT_PRODUCTS_DIR}
rm -rf build-msp
# extractor output from an earlier build
rm -rf data/mods/base/base_gamestate

# no vcpkg: SDL2, Boost and libvorbis come from /usr/local. The Qt launcher
# isn't built. The build rpath into /usr/local is needed by the code
# generator run during the build; copy_dependencies.sh removes it from the
# bundled executable.
cmake -G Ninja -B build-msp \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION} \
	-DCMAKE_PREFIX_PATH=/usr/local \
	-DBUILD_LAUNCHER=OFF \
	-DENABLE_TESTS=OFF \
	-DCD_PATH="${CD_PATH}" \
	.

cmake --build build-msp --parallel $NCPU

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"
cp build-msp/bin/OpenApoc.app/Contents/MacOS/${EXECUTABLE_NAME} "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

# the game's data (including the extracted base game state) goes in
# Resources, which the game uses as its working directory
RESOURCES="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
ditto data "${RESOURCES}/data"
rm -f "${RESOURCES}/data/cd.iso" "${RESOURCES}/data/readme.txt"
cp LICENSE README.md README_HOTKEYS.md "${RESOURCES}"

# bundle the /usr/local libraries
cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
