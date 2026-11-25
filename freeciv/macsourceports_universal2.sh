# game/app specific values
export APP_VERSION="3.2.7"
export PRODUCT_NAME="Freeciv"
export PROJECT_NAME="freeciv"
export PORT_NAME="Freeciv"
export ICONSFILENAME="freeciv"
export EXECUTABLE_NAME="freeciv-sdl2"
export PKGINFO="APPLFCIV"

# constants
source ../common/constants.sh
source ../common/signing_values.local
# the /usr/local libraries it links against (SDL2 etc.) are 11.0+
export MINIMUM_SYSTEM_VERSION="11.0"
export MACOSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION}

PATCH_DIR=$PWD

cd ../../${PROJECT_NAME}

# macOS app bundle support -- see the patch. When the programs run from
# inside an app bundle, the data and scenarios are looked for in
# ~/.freeciv/<version> (where the modpack installer puts things) and then in
# Contents/Resources/freeciv, the translations in Contents/Resources/locale,
# and the client starts the freeciv-server beside it in Contents/MacOS for
# single player games. Outside a bundle nothing changes.
# Skip if it's already applied.
if ! git apply -R --check "${PATCH_DIR}/msp-macos.patch" 2>/dev/null; then
	git apply "${PATCH_DIR}/msp-macos.patch" || exit 1
fi

# Release tags are R<major>_<minor>_<patch>, e.g. R3_2_7 is 3.2.7
if [ -n "$2" ]; then
	VERSION_FROM_TAG="${2#R}"
	export APP_VERSION="${VERSION_FROM_TAG//_/.}"
	echo "Setting version to: $APP_VERSION"
else
	export APP_VERSION="$(./fc_version)"
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}

# The SDL2 client: the GTK and Qt clients would need GTK or Qt built in
# /usr/local. Sound through SDL2_mixer. No ruleset editor, manual or
# modpack installer.
MESON_OPTIONS=(
	--buildtype=release
	--prefix=/
	-Ddebug=false
	-Dclients=sdl2
	-Dfcmp=cli
	-Daudio=sdl2
	-Dtools=
	-Dreadline=true
	-Dmwand=false
	-Dnls=true
)

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

# One build per architecture, lipo'd together below. Meson can't do both
# at once (its header checks run the preprocessor, which refuses more than
# one -arch). arm64 is a native build; x86_64 is a cross build, so it can't
# run the tolua it builds and uses the arm64 one instead. A cross build only
# searches the one folder given as cross_lib_path for libraries, so that's a
# folder of links to /usr/local/lib plus the system iconv, charset and bz2
# that the native build finds in the SDK.
rm -rf build-msp-arm64 build-msp-x86_64 libs-msp-x86_64 stage-msp-arm64 stage-msp-x86_64
mkdir -p build-msp-arm64 build-msp-x86_64 libs-msp-x86_64

SDK_PATH="$(xcrun --sdk macosx --show-sdk-path)"
for f in /usr/local/lib/*; do
	ln -s "$f" libs-msp-x86_64/
done
for l in iconv charset bz2; do
	ln -sf "${SDK_PATH}/usr/lib/lib${l}.tbd" "libs-msp-x86_64/lib${l}.dylib"
done

compile_args() {
	echo "['-arch', '$1', '-mmacosx-version-min=${MINIMUM_SYSTEM_VERSION}', '-I/usr/local/include'$2]"
}
link_args() {
	echo "['-arch', '$1', '-mmacosx-version-min=${MINIMUM_SYSTEM_VERSION}', '-L/usr/local/lib']"
}

cat > build-msp-arm64/native-msp.txt <<EOF
[built-in options]
c_args = $(compile_args arm64)
cpp_args = $(compile_args arm64)
objc_args = $(compile_args arm64)
c_link_args = $(link_args arm64)
cpp_link_args = $(link_args arm64)
objc_link_args = $(link_args arm64)
EOF

# MALLOC_ZERO_OK comes from a check that runs a program, which a cross
# build skips. It's true for macOS on both architectures.
cat > build-msp-x86_64/cross-msp.txt <<EOF
[binaries]
c = '/usr/bin/clang'
cpp = '/usr/bin/clang++'
objc = '/usr/bin/clang'
ar = 'ar'
strip = 'strip'
pkg-config = 'pkg-config'
tolua = '${PWD}/build-msp-arm64/tolua'

[properties]
needs_exe_wrapper = false
cross_lib_path = '${PWD}/libs-msp-x86_64'
cross_inc_path = '/usr/local/include'

[built-in options]
c_args = $(compile_args x86_64 ", '-DMALLOC_ZERO_OK=1'")
cpp_args = $(compile_args x86_64 ", '-DMALLOC_ZERO_OK=1'")
objc_args = $(compile_args x86_64 ", '-DMALLOC_ZERO_OK=1'")
c_link_args = $(link_args x86_64)
cpp_link_args = $(link_args x86_64)
objc_link_args = $(link_args x86_64)

[host_machine]
system = 'darwin'
cpu_family = 'x86_64'
cpu = 'x86_64'
endian = 'little'
EOF

meson setup build-msp-arm64 --native-file=build-msp-arm64/native-msp.txt "${MESON_OPTIONS[@]}" || exit 1
ninja -C build-msp-arm64 || exit 1
DESTDIR="${PWD}/stage-msp-arm64" meson install -C build-msp-arm64 --no-rebuild || exit 1

meson setup build-msp-x86_64 --cross-file=build-msp-x86_64/cross-msp.txt "${MESON_OPTIONS[@]}" || exit 1
ninja -C build-msp-x86_64 || exit 1
DESTDIR="${PWD}/stage-msp-x86_64" meson install -C build-msp-x86_64 --no-rebuild || exit 1

# The two builds must have found the same things (x86_64 gets
# MALLOC_ZERO_OK from its compiler arguments instead)
if ! diff -I MALLOC_ZERO_OK build-msp-arm64/fc_config.h build-msp-x86_64/fc_config.h ||
   ! diff build-msp-arm64/freeciv_config.h build-msp-x86_64/freeciv_config.h; then
	echo "Error: the arm64 and x86_64 builds are configured differently"
	exit 1
fi

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

for exe in freeciv-sdl2 freeciv-server; do
	lipo -create -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${exe}" \
		"stage-msp-arm64/bin/${exe}" "stage-msp-x86_64/bin/${exe}" || exit 1
done
mkdir -p "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
lipo -create -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libfreeciv.dylib" \
	stage-msp-arm64/lib/libfreeciv.dylib stage-msp-x86_64/lib/libfreeciv.dylib || exit 1

# the game data (rulesets, tilesets, sounds, music, scenarios) and translations
cp -R stage-msp-arm64/share/freeciv "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/" || exit 1
cp -R stage-msp-arm64/share/locale "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/" || exit 1

# bundle the /usr/local libraries
cd "${BUILT_PRODUCTS_DIR}"

# meson install gives libfreeciv its install path (/lib/libfreeciv.dylib,
# with the / prefix) as its name, and the server is relinked against that.
# Some /usr/local libraries (sqlite) also have their full path as their
# install name, which copy_dependencies doesn't follow. Point all of those
# at @rpath.
install_name_tool -id @rpath/libfreeciv.dylib "${FRAMEWORKS_FOLDER_PATH}/libfreeciv.dylib"
for f in "${EXECUTABLE_FOLDER_PATH}"/* "${FRAMEWORKS_FOLDER_PATH}/libfreeciv.dylib"; do
	for lib in $(otool -L "$f" | awk '{print $1}' | grep -E '^/usr/local/lib/|^/lib/libfreeciv'); do
		install_name_tool -change "$lib" "@rpath/$(basename "$lib")" "$f"
	done
done

for f in "${EXECUTABLE_FOLDER_PATH}/freeciv-sdl2" "${EXECUTABLE_FOLDER_PATH}/freeciv-server" "${FRAMEWORKS_FOLDER_PATH}/libfreeciv.dylib"; do
	"../../MSPBuildSystem/common/copy_dependencies.sh" "$f" "${FRAMEWORKS_FOLDER_PATH}"
done
# and give the copies of those libraries an @rpath install name too
for f in "${FRAMEWORKS_FOLDER_PATH}"/*.dylib; do
	if [ -f "$f" ] && [ ! -L "$f" ] && otool -D "$f" | tail -n +2 | grep -q '^/usr/local/'; then
		chmod u+w "$f"
		install_name_tool -id "@rpath/$(otool -D "$f" | tail -1 | xargs basename)" "$f"
	fi
done

# copy_dependencies skips libraries it can't find in /usr/local/lib, which
# would give an app that dies at launch. Stop here instead.
for lib in $(otool -L "${EXECUTABLE_FOLDER_PATH}"/* "${FRAMEWORKS_FOLDER_PATH}"/*.dylib | grep -o '@rpath/[^ ]*' | sort -u); do
	if [ ! -e "${FRAMEWORKS_FOLDER_PATH}/${lib#@rpath/}" ]; then
		echo "Error: ${lib#@rpath/} is not in the bundle (is it installed in /usr/local/lib?)"
		exit 1
	fi
done
# Everything must come from the bundle or the system
if otool -L "${EXECUTABLE_FOLDER_PATH}"/* "${FRAMEWORKS_FOLDER_PATH}"/*.dylib | grep -E '^\s' | grep -vqE '^\s+(@rpath/|/usr/lib/|/System/)'; then
	echo "Error: something in the bundle links outside the bundle and the system:"
	otool -L "${EXECUTABLE_FOLDER_PATH}"/* "${FRAMEWORKS_FOLDER_PATH}"/*.dylib | grep -E ':$|^\s' | grep -vE '^\s+(@rpath/|/usr/lib/|/System/)'
	exit 1
fi
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
