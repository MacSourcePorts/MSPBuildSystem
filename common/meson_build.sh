if [ -z "${MACOSX_DEPLOYMENT_TARGET}" ]; then
    export MACOSX_DEPLOYMENT_TARGET="10.7"
fi

if [ -z "${CROSS_FILE_X86_64}" ]; then
    export CROSS_FILE_X86_64="../../../cross-x86_64.txt"
fi

if [ -z "${CROSS_FILE_ARM64}" ]; then
    export CROSS_FILE_ARM64="../../../cross-arm64.txt"
fi

export PATH=$PATH:~/Library/Python/3.9/bin/

if [ -z "${SOURCE_FOLDER}" ]; then
    cd source/${SOURCE_FILE}
else
    cd source/${SOURCE_FOLDER}
fi

mkdir build-x86_64 build-arm64 build-universal2

export CC="/usr/bin/clang"
export CXX="/usr/bin/clang++"

export CFLAGS="-arch x86_64"
export LDFLAGS="-arch x86_64"

cd build-x86_64
meson setup ${MESON_FLAGS} --cross-file=${CROSS_FILE_X86_64} --prefix=/usr/local --libdir=lib --buildtype=release ../${SOURCE_DIR}
ninja
cd ..

export CFLAGS="-arch arm64"
export LDFLAGS="-arch arm64"

cd build-arm64
meson setup ${MESON_FLAGS} --cross-file=${CROSS_FILE_ARM64} --prefix=/usr/local --libdir=lib --buildtype=release ../${SOURCE_DIR}
ninja

# Apparently the "install" does more than just copy the dylibs
# so I'm going to let it do its thing in the build-arm64 folder
# and then just lipo the dylibs directly
sudo ninja install
cd ..

cp -r build-arm64/. build-universal2

cd build-arm64
for i in `find . -name "*.dylib" -type f`; do
    # echo "$i"
    LIB_NAME=${i##*/}
    LIB_PATH=${i##./}

    echo sudo lipo -create -output /usr/local/lib/${LIB_NAME} ../build-arm64/${LIB_PATH} ../build-x86_64/${LIB_PATH}
    sudo lipo -create -output /usr/local/lib/${LIB_NAME} ../build-arm64/${LIB_PATH} ../build-x86_64/${LIB_PATH}
done