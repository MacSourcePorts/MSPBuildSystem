# TRX (Tomb Raider I-III Community Edition): one engine, shipped as an app
# per game -- TR1X, TR2X and TR3X -- each with its own DMG.

# game/app specific values (the first app's; the others are set below)
export APP_VERSION="1.12"
export PRODUCT_NAME="TR1X"
export PROJECT_NAME="TRX"
export PORT_NAME="TR1X"
export ICONSFILENAME="tr1x"
export EXECUTABLE_NAME="TRX"
export PKGINFO="APPLTR1X"

# constants
source ../common/constants.sh
source ../common/signing_values.local
# the /usr/local libraries it links against (SDL2, FFmpeg etc.) are 11.0+
export MINIMUM_SYSTEM_VERSION="11.0"
export MACOSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION}

LUA_VERSION="5.4.8"

PATCH_DIR=$PWD

cd ../../${PROJECT_NAME}

# macOS app support -- see the patch. In an app whose Info.plist has an
# MSPDataFolder key (TombRaider1 etc.), the original game's files are found
# in ~/Library/Application Support/<MSPDataFolder> as the GOG/Steam release
# installs them (TR1's GAME.GOG disc image is extracted there on the first
# run, and its 02.mp3 ... music used as it is), and the settings, saves and
# log go in ~/Library/Application Support/TRX. Also fixes the Lua watchdog
# blaming a slow window/GL setup on the next script. Skip if it's applied.
if ! git apply -R --check "${PATCH_DIR}/msp-macos.patch" 2>/dev/null; then
	git apply "${PATCH_DIR}/msp-macos.patch" || exit 1
fi

# Release tags are trx-<version>, e.g. trx-1.12
if [ -n "$2" ]; then
	export APP_VERSION="${2#trx-}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}

# The freely distributable files TRX ships (images, injections, the TR1 PC
# demo, the TR2 Golden Mask expansion) go into data/trx/ship
python3 tools/download_assets 1 || exit 1
python3 tools/download_assets 2 || exit 1
python3 tools/download_assets 3 || exit 1

# TRX needs Lua 5.4 (/usr/local has 5.5, which changes the language), so
# build a static universal one just for it, as TRX's own Linux and Windows
# builds do
rm -rf lua-msp
mkdir -p lua-msp/include lua-msp/lib
curl -fsSL "https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz" | tar -xz -C lua-msp || exit 1
for f in lua-msp/lua-${LUA_VERSION}/src/*.c; do
	case "$(basename "$f")" in lua.c|luac.c) continue ;; esac
	clang -c -O2 -arch arm64 -arch x86_64 -mmacosx-version-min=${MINIMUM_SYSTEM_VERSION} \
		-DLUA_USE_MACOSX -o "lua-msp/$(basename "${f%.c}").o" "$f" || exit 1
done
/usr/bin/libtool -static -o lua-msp/lib/liblua.a lua-msp/*.o || exit 1
cp lua-msp/lua-${LUA_VERSION}/src/{lua.h,luaconf.h,lualib.h,lauxlib.h,lua.hpp} lua-msp/include/
# the full path to the archive, so the linker can't pick /usr/local's 5.5
cat > lua-msp/lua.pc <<EOF
prefix=${PWD}/lua-msp
Name: Lua
Description: Lua ${LUA_VERSION} (static, for TRX)
Version: ${LUA_VERSION}
Libs: \${prefix}/lib/liblua.a
Cflags: -I\${prefix}/include
EOF

# uthash comes from /usr/local/include (see libraries/uthash.sh)
export PKG_CONFIG_PATH="${PWD}/lua-msp:/usr/local/lib/pkgconfig"

MESON_OPTIONS=(
	--buildtype=release
	--prefix=/
	-Dtrx_version=${APP_VERSION}
)

# One build per architecture, lipo'd together below. Meson can't do both at
# once (its header checks run the preprocessor, which refuses more than one
# -arch), and an x86_64 native build fails its sanity check without Rosetta,
# so x86_64 is a cross build.
rm -rf build-msp-arm64 build-msp-x86_64
mkdir -p build-msp-arm64 build-msp-x86_64

compile_args() {
	echo "['-arch', '$1', '-mmacosx-version-min=${MINIMUM_SYSTEM_VERSION}', '-I/usr/local/include']"
}
link_args() {
	echo "['-arch', '$1', '-mmacosx-version-min=${MINIMUM_SYSTEM_VERSION}', '-L/usr/local/lib']"
}

cat > build-msp-arm64/native-msp.txt <<EOF
[built-in options]
c_args = $(compile_args arm64)
c_link_args = $(link_args arm64)
EOF

cat > build-msp-x86_64/cross-msp.txt <<EOF
[binaries]
c = '/usr/bin/clang'
ar = 'ar'
strip = 'strip'
pkg-config = 'pkg-config'

[properties]
needs_exe_wrapper = false

[built-in options]
c_args = $(compile_args x86_64)
c_link_args = $(link_args x86_64)

[host_machine]
system = 'darwin'
cpu_family = 'x86_64'
cpu = 'x86_64'
endian = 'little'
EOF

meson setup build-msp-arm64 src --native-file=build-msp-arm64/native-msp.txt "${MESON_OPTIONS[@]}" || exit 1
ninja -C build-msp-arm64 || exit 1
meson setup build-msp-x86_64 src --cross-file=build-msp-x86_64/cross-msp.txt "${MESON_OPTIONS[@]}" || exit 1
ninja -C build-msp-x86_64 || exit 1

# drop the build-machine rpath (/usr/local/lib), which would make the app
# load /usr/local's libraries instead of its own, then lipo
for arch in arm64 x86_64; do
	for rpath in $(otool -l "build-msp-${arch}/TRX" | awk '/cmd LC_RPATH/{getline; getline; print $2}' | sort -u); do
		install_name_tool -delete_rpath "$rpath" "build-msp-${arch}/TRX" || exit 1
	done
done
mkdir -p build-msp-universal
lipo -create -output build-msp-universal/TRX build-msp-arm64/TRX build-msp-x86_64/TRX || exit 1

SHIP="data/trx/ship"

# make_app <1|2|3>: the app for one game. It carries the shared files and
# that game's folders only (its base game, expansion and single-level mode),
# so it shows that game alone.
make_app() {
	local n=$1

	export PRODUCT_NAME="TR${n}X"
	export PORT_NAME="TR${n}X"
	export PKGINFO="APPLTR${n}X"
	export ICONSFILENAME="tr${n}x"
	export EXTRA_INFO_PLIST_ENTRIES="
    <key>MSPDataFolder</key>
    <string>TombRaider${n}</string>"

	# have to re-do all the variables cascading down from PRODUCT_NAME
	export WRAPPER_NAME="${PRODUCT_NAME}.app"
	export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
	export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
	export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"
	export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
	export FRAMEWORKS_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Frameworks"
	export ICONS="${ICONSFILENAME}.icns"

	rm -rf "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
	"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" || exit 1
	cp build-msp-universal/TRX "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/" || exit 1

	local RESOURCES="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
	cp -R "${SHIP}/cfg" "${SHIP}/modules" "${SHIP}/scripts" "${RESOURCES}/" || exit 1
	mkdir -p "${RESOURCES}/games"
	cp -R "${SHIP}/games/tr${n}" "${SHIP}/games/tr${n}"-* "${RESOURCES}/games/" || exit 1

	# bundle the /usr/local libraries
	cd "${BUILT_PRODUCTS_DIR}"
	"../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${FRAMEWORKS_FOLDER_PATH}"
	# some /usr/local libraries have their full path as their install name
	# (or a /usr/local rpath of their own); point those at the bundle
	for f in "${FRAMEWORKS_FOLDER_PATH}"/*.dylib; do
		[ -f "$f" ] && [ ! -L "$f" ] || continue
		chmod u+w "$f"
		if otool -D "$f" | tail -n +2 | grep -q '^/usr/local/'; then
			install_name_tool -id "@rpath/$(otool -D "$f" | tail -1 | xargs basename)" "$f"
		fi
		for lib in $(otool -L "$f" | awk '{print $1}' | grep '^/usr/local/lib/'); do
			install_name_tool -change "$lib" "@rpath/$(basename "$lib")" "$f"
		done
		for rpath in $(otool -l "$f" | awk '/cmd LC_RPATH/{getline; getline; print $2}' | grep '^/usr/local' | sort -u); do
			install_name_tool -delete_rpath "$rpath" "$f"
		done
	done

	# copy_dependencies skips libraries it can't find in /usr/local/lib,
	# which would give an app that dies at launch. Stop here instead.
	for lib in $(otool -L "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${FRAMEWORKS_FOLDER_PATH}"/*.dylib | grep -o '@rpath/[^ ]*' | sort -u); do
		if [ ! -e "${FRAMEWORKS_FOLDER_PATH}/${lib#@rpath/}" ]; then
			echo "Error: ${lib#@rpath/} is not in the bundle (is it installed in /usr/local/lib?)"
			exit 1
		fi
	done
	# Everything must come from the bundle or the system
	if otool -L "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${FRAMEWORKS_FOLDER_PATH}"/*.dylib | grep -E '^\s' | grep -vqE '^\s+(@rpath/|@loader_path/|@executable_path/|/usr/lib/|/System/)'; then
		echo "Error: something in the bundle links outside the bundle and the system:"
		otool -L "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${FRAMEWORKS_FOLDER_PATH}"/*.dylib | grep -E ':$|^\s' | grep -vE '^\s+(@rpath/|@loader_path/|@executable_path/|/usr/lib/|/System/)'
		exit 1
	fi
	cd ..

	# sign and notarize
	"../MSPBuildSystem/common/sign_and_notarize.sh" "$SIGN_ARG" || exit 1
}

SIGN_ARG="$1"

# All three DMGs go in the one release folder: the first app makes it, and
# the build folders are cleaned up after the last
make_app 1
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup" || exit 1
make_app 2
"../MSPBuildSystem/common/package_dmg.sh" "skipdelete" "skipcleanup" || exit 1
make_app 3
"../MSPBuildSystem/common/package_dmg.sh" "skipdelete" || exit 1

rm -rf build-msp-arm64 build-msp-x86_64 build-msp-universal lua-msp
