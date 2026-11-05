# game/app specific values
export APP_VERSION="0.68.0"
export PRODUCT_NAME="CorsixTH"
export PROJECT_NAME="CorsixTH"
export PORT_NAME="CorsixTH"
export ICONSFILENAME="CorsixTH"
export EXECUTABLE_NAME="CorsixTH"
export PKGINFO="APPLCTH"

# constants
source ../common/constants.sh
source ../common/signing_values.local
export MINIMUM_SYSTEM_VERSION="10.15"

export ENTITLEMENTS_FILE="CorsixTH.entitlements"
export HIGH_RESOLUTION_CAPABLE="true"

cd ../../${PROJECT_NAME}
SCRIPT_DIR=$PWD

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

# Turning off the bundling for now
gsed -i '/FIXUP_BUNDLE(.*CorsixTH\.app.*)/d' CorsixTH/CMakeLists.txt

# fix for grep of Universal 2 binaries
gsed -i "s|grep 'lua'*|grep -m1 'lua'|" scripts/macos_luarocks

rm -rf ${BUILT_PRODUCTS_DIR}
export RANLIB=/usr/bin/ranlib
export AR=/usr/bin/ar

# Making special version of libraries because of sdl2_mixer issue
rm -rf lib
mkdir lib

rm -rf libsrc
mkdir libsrc

export PREFIX_DIR="$PWD/lib/"

echo ${PREFIX_DIR}

cd libsrc
# sdl2
curl -JLO https://github.com/libsdl-org/SDL/releases/download/release-2.30.3/SDL2-2.30.3.zip
unzip SDL2-2.30.3.zip
# libxmp
curl -JLO https://downloads.sourceforge.net/project/xmp/libxmp/4.6.0/libxmp-4.6.0.tar.gz
tar -xzvf libxmp-4.6.0.tar.gz
# wavpack
curl -JLO https://www.wavpack.com/wavpack-5.7.0.tar.bz2
tar -xzvf wavpack-5.7.0.tar.bz2
# ogg
curl -JLO https://gitlab.xiph.org/xiph/ogg/-/archive/v1.3.5/ogg-v1.3.5.zip
unzip ogg-v1.3.5.zip
# opus
curl -JLO https://downloads.xiph.org/releases/opus/opus-1.5.2.tar.gz
tar -xzvf opus-1.5.2.tar.gz
# opusfile
curl -JLO https://gitlab.xiph.org/xiph/opusfile/-/archive/v0.12/opusfile-v0.12.tar.gz
tar -xzvf opusfile-v0.12.tar.gz
# sdl2_mixer
curl -JLO https://github.com/libsdl-org/SDL_mixer/releases/download/release-2.8.0/SDL2_mixer-2.8.0.zip
unzip SDL2_mixer-2.8.0.zip
# rtmidi
curl -JLO https://github.com/thestk/rtmidi/archive/refs/tags/6.0.0.tar.gz
tar -xzvf rtmidi-6.0.0.tar.gz
# lua 5.4 - CorsixTH (and CMake's FindLua) don't support 5.5, which is what's in /usr/local now
curl -JLO https://www.lua.org/ftp/lua-5.4.8.tar.gz
tar -xzvf lua-5.4.8.tar.gz

(cd SDL2-*; ./configure --disable-joystick --disable-haptic --prefix=${PREFIX_DIR} CFLAGS='-arch x86_64 -arch arm64  -mmacosx-version-min=10.7' LDFLAGS='-arch x86_64 -arch arm64 -mmacosx-version-min=10.7'; make clean; make -j$NCPU install)
install_name_tool -id @rpath/libSDL2-2.0.0.dylib ${PREFIX_DIR}lib/libSDL2-2.0.0.dylib
(cd libxmp*; rm -rf build; cmake -Bbuild . -DCMAKE_INSTALL_PREFIX=${PREFIX_DIR} -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"  -DCMAKE_POLICY_VERSION_MINIMUM=3.5; cmake --build build/ --target install)
install_name_tool -id @rpath/libxmp.4.6.0.dylib ${PREFIX_DIR}lib/libxmp.4.6.0.dylib
(cd wavpack*; ./configure --disable-apps --prefix=${PREFIX_DIR} CFLAGS='-arch x86_64 -arch arm64 -mmacosx-version-min=10.7'; make clean; make -j$NCPU install)
(cd ogg-*; ./autogen.sh; ./configure --prefix=${PREFIX_DIR} CFLAGS='-arch x86_64 -arch arm64 -mmacosx-version-min=10.7' LDFLAGS='-arch x86_64 -arch arm64 -mmacosx-version-min=10.7'; make clean; make -j$NCPU install)
install_name_tool -id @rpath/libogg.0.dylib ${PREFIX_DIR}lib/libogg.0.dylib
(cd opus-*; ./configure --disable-doc --disable-extra-programs --prefix=${PREFIX_DIR} CFLAGS='-arch x86_64 -arch arm64  -mmacosx-version-min=10.7'; make clean; make -j$NCPU install)
install_name_tool -id @rpath/libopus.0.dylib ${PREFIX_DIR}lib/libopus.0.dylib
(cd opusfile-*; ./autogen.sh; ./configure --disable-doc --disable-examples --disable-http --disable-silent-rules --prefix=${PREFIX_DIR} CFLAGS='-arch x86_64 -arch arm64  -mmacosx-version-min=10.7' LDFLAGS='-L${PREFIX_DIR}lib'; make clean; make -j$NCPU install)
install_name_tool -id @rpath/libopusfile.0.dylib ${PREFIX_DIR}lib/libopusfile.0.dylib
(cd SDL2_mixer*; rm -rf build; cmake -Bbuild . -DSDL2MIXER_MIDI_FLUIDSYNTH=OFF -DSDL2MIXER_MIDI_TIMIDITY=OFF \
-DSDL2MIXER_WAVPACK=ON -DSDL2MIXER_DEPS_SHARED=ON -DBUILD_SHARED_LIBS=ON -DSDL2MIXER_WAVE=ON \
-DSDL2MIXER_OPUS=ON -DCMAKE_INSTALL_PREFIX=${PREFIX_DIR} -DSDL2_INCLUDE_DIR=${PREFIX_DIR}include/SDL2/ \
-DOpusFile_INCLUDE_PATH=${PREFIX_DIR}include/opus/ -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DSDL2_DIR=${PREFIX_DIR}lib/cmake/SDL2 -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build/ --target install)
install_name_tool -id @rpath/libSDL2_mixer-2.0.801.0.0.dylib ${PREFIX_DIR}lib/libSDL2_mixer-2.0.801.0.0.dylib
# built with CMake so it installs rtmidi-config.cmake; CorsixTH's pkg-config fallback links a bare -lrtmidi with no -L
(cd rtmidi-6.0.0; rm -rf build; cmake -Bbuild . -DCMAKE_INSTALL_PREFIX=${PREFIX_DIR} -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 -DRTMIDI_BUILD_TESTING=OFF -DCMAKE_INSTALL_NAME_DIR=@rpath -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build/ --target install -j$NCPU)
(cd lua-5.4.8/src; make liblua.a SYSCFLAGS="-DLUA_USE_MACOSX" MYCFLAGS="-arch x86_64 -arch arm64 -mmacosx-version-min=10.15" AR="/usr/bin/ar rcu" RANLIB=/usr/bin/ranlib
mkdir -p ${PREFIX_DIR}include/lua ${PREFIX_DIR}lib
cp lua.h luaconf.h lualib.h lauxlib.h lua.hpp ${PREFIX_DIR}include/lua/
cc -dynamiclib -arch x86_64 -arch arm64 -mmacosx-version-min=10.15 -install_name @rpath/liblua.5.4.dylib \
-compatibility_version 5.4 -current_version 5.4.8 -o ${PREFIX_DIR}lib/liblua.5.4.dylib -Wl,-all_load liblua.a)

cd ..

export LDFLAGS="-L${PREFIX_DIR}lib $LDFLAGS"

mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
cmake \
.. \
-DDISABLE_WERROR=1 \
-DCMAKE_OSX_ARCHITECTURES=arm64  \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_INSTALL_PREFIX=${SCRIPT_DIR}/${BUILT_PRODUCTS_DIR} \
-DCMAKE_PREFIX_PATH=${PREFIX_DIR} \
-DCMAKE_LIBRARY_PATH=${PREFIX_DIR}/lib \
-DWITH_LUAROCKS=on \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DLUA_LIBRARY=${PREFIX_DIR}lib/liblua.5.4.dylib \
-DLUA_INCLUDE_DIR=${PREFIX_DIR}include/lua \
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
-DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
make CorsixTH -j8 VERBOSE=1
make install
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH} ${PREFIX_DIR}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/lpeg.so

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/lfs.so

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh" #"skipcleanup"
rm -rf lib   
rm -rf libsrc