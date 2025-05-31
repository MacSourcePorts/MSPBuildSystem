# game/app specific values
export APP_VERSION="0.68.0"
export PRODUCT_NAME="CorsixTH"
export PROJECT_NAME="CorsixTH"
export PORT_NAME="CorsixTH"
export ICONSFILENAME="CorsixTH"
export EXECUTABLE_NAME="CorsixTH"
export PKGINFO="APPLCTH"
export GIT_TAG="v0.68.0"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh
source ../common/signing_values.local

export ENTITLEMENTS_FILE="CorsixTH.entitlements"
export HIGH_RESOLUTION_CAPABLE="true"

cd ../../${PROJECT_NAME}
SCRIPT_DIR=$PWD

if [ -n "$3" ]; then
	export APP_VERSION="${3/v/}"
	export GIT_TAG="$3"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"

    # reset to the main branch
    echo git restore .
    git restore .
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}

    # fetch the latest 
    echo git pull
    git pull

    # check out the latest release tag
    echo git checkout tags/${GIT_TAG}
    git checkout tags/${GIT_TAG}
fi

# Turning off the bundling for now
gsed -i '/FIXUP_BUNDLE(.*CorsixTH\.app.*)/d' CorsixTH/CMakeLists.txt

# fix for grep of Universal 2 binaries
gsed -i "s|grep 'lua'*|grep -m1 'lua'|" scripts/macos_luarocks

rm -rf ${BUILT_PRODUCTS_DIR}
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
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

    (cd SDL2-*; ./configure --disable-joystick --disable-haptic --prefix=${PREFIX_DIR} CFLAGS='-arch x86_64 -arch arm64  -mmacosx-version-min=10.7' LDFLAGS='-arch x86_64 -arch arm64 -mmacosx-version-min=10.7'; make clean; make -j$NCPU install)
    install_name_tool -id @rpath/libSDL2-2.0.0.dylib ${PREFIX_DIR}lib/libSDL2-2.0.0.dylib
    (cd libxmp*; rm -rf build; cmake -Bbuild . -DCMAKE_INSTALL_PREFIX=${PREFIX_DIR} -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"; cmake --build build/ --target install)
    install_name_tool -id @rpath/libxmp.4.6.0.dylib ${PREFIX_DIR}lib/libxmp.4.6.0.dylib
    (cd wavpack*; ./configure --disable-apps --prefix=${PREFIX_DIR} CFLAGS='-arch x86_64 -arch arm64  -mmacosx-version-min=10.7'; make clean; make -j$NCPU install)
    (cd ogg-*; ./autogen.sh; ./configure --prefix=${PREFIX_DIR} CFLAGS='-arch x86_64 -arch arm64  -mmacosx-version-min=10.7' LDFLAGS='-arch x86_64 -arch arm64 -mmacosx-version-min=10.7'; make clean; make -j$NCPU install)
    install_name_tool -id @rpath/libogg.0.dylib ${PREFIX_DIR}lib/libogg.0.dylib
    (cd opus-*; ./configure --disable-doc --disable-extra-programs --prefix=${PREFIX_DIR} CFLAGS='-arch x86_64 -arch arm64  -mmacosx-version-min=10.7'; make clean; make -j$NCPU install)
    install_name_tool -id @rpath/libopus.0.dylib ${PREFIX_DIR}lib/libopus.0.dylib
    (cd opusfile-*; ./autogen.sh; ./configure --disable-doc --disable-examples --disable-http --disable-silent-rules --prefix=${PREFIX_DIR} CFLAGS='-arch x86_64 -arch arm64  -mmacosx-version-min=10.7' LDFLAGS='-L${PREFIX_DIR}lib'; make clean; make -j$NCPU install)
    install_name_tool -id @rpath/libopusfile.0.dylib ${PREFIX_DIR}lib/libopusfile.0.dylib
    (cd SDL2_mixer*; rm -rf build; cmake -Bbuild . -DSDL2MIXER_MIDI_FLUIDSYNTH=OFF -DSDL2MIXER_MIDI_TIMIDITY=OFF \
    -DSDL2MIXER_WAVPACK=ON -DSDL2MIXER_DEPS_SHARED=ON -DBUILD_SHARED_LIBS=ON -DSDL2MIXER_WAVE=ON \
    -DSDL2MIXER_OPUS=ON -DCMAKE_INSTALL_PREFIX=${PREFIX_DIR} -DSDL2_INCLUDE_DIR=${PREFIX_DIR}include/SDL2/ \
    -DOpusFile_INCLUDE_PATH=${PREFIX_DIR}include/opus/ -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DSDL2_DIR=${PREFIX_DIR}lib/cmake/SDL2
    cmake --build build/ --target install)
    install_name_tool -id @rpath/libSDL2_mixer-2.0.801.0.0.dylib ${PREFIX_DIR}lib/libSDL2_mixer-2.0.801.0.0.dylib

    cd ..

	mkdir ${BUILT_PRODUCTS_DIR}
    cd ${BUILT_PRODUCTS_DIR}
    cmake \
    .. \
    -DDISABLE_WERROR=1 \
    -DCMAKE_OSX_ARCHITECTURES=arm64  \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_INSTALL_PREFIX=${SCRIPT_DIR}/${BUILT_PRODUCTS_DIR} \
    -DCMAKE_PREFIX_PATH=${PREFIX_DIR} \
    -DWITH_LUAROCKS=on \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 \
    -DLUA_LIBRARY=/usr/local/lib/liblua.5.4.dylib \
    -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
    make CorsixTH -j8
    make install
    "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH} ${PREFIX_DIR}
else
    # hotfix for issue with luarocks script
    cp -rf "../MSPBuildSystem/CorsixTH/macos_luarocks" "scripts"

    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}
    cd ${ARM64_BUILD_FOLDER}
    cmake \
    .. \
    -DDISABLE_WERROR=1 \
    -DCMAKE_OSX_ARCHITECTURES=arm64  \
    -DCMAKE_INSTALL_PREFIX=${SCRIPT_DIR}/${ARM64_BUILD_FOLDER} \
    -DCMAKE_PREFIX_PATH=${PREFIX_DIR}libs/arm64 \
    -DWITH_LUAROCKS=on \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 \
    -DLUA_LIBRARY=/opt/Homebrew/lib/liblua.5.4.dylib \
    -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
    make CorsixTH -j8
    make install

    cd ..
    rm -rf ${X86_64_BUILD_FOLDER}
    mkdir ${X86_64_BUILD_FOLDER}
    cd ${X86_64_BUILD_FOLDER}
    /usr/local/bin/cmake \
    .. \
    -DDISABLE_WERROR=1 \
    -DCMAKE_OSX_ARCHITECTURES=x86_64  \
    -DCMAKE_INSTALL_PREFIX=${SCRIPT_DIR}/${X86_64_BUILD_FOLDER} \
    -DCMAKE_PREFIX_PATH=${PREFIX_DIR}libs/x86_64 \
    -DWITH_LUAROCKS=on \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 \
    -DLUA_LIBRARY=/usr/local/lib/liblua.5.4.dylib \
    -DLUA_PROGRAM_PATH=/usr/local/bin/lua \
    -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
    make CorsixTH -j8
    make install
fi
cd ..

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"
else
    "../MSPBuildSystem/common/build_app_bundle.sh"
    lipo ${X86_64_BUILD_FOLDER}/${WRAPPER_NAME}/Contents/Resources/lpeg.so ${ARM64_BUILD_FOLDER}/${WRAPPER_NAME}/Contents/Resources/lpeg.so -output "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/lpeg.so" -create
    lipo ${X86_64_BUILD_FOLDER}/${WRAPPER_NAME}/Contents/Resources/lfs.so ${ARM64_BUILD_FOLDER}/${WRAPPER_NAME}/Contents/Resources/lfs.so -output "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/lfs.so" -create
fi

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/lpeg.so

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/lfs.so

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" #"skipcleanup"
rm -rf lib   
rm -rf libsrc