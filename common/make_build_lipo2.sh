# TODO: This is a one-off for vpx. Figure out if we can merge it with the original.
if [ -z "${MACOSX_DEPLOYMENT_TARGET}" ]; then
    export MACOSX_DEPLOYMENT_TARGET="10.7"
fi
export NCPU=`sysctl -n hw.ncpu`

cd source/${SOURCE_FOLDER}

./autogen.sh

mkdir build-arm64 build-x86_64 build-universal2

# Build for x86_64

export CC="$(xcrun -f clang) -arch x86_64"
export CXX="$(xcrun -f clang++) -arch x86_64"
export CFLAGS="-arch x86_64"
export LDFLAGS="-arch x86_64"

cd build-x86_64
../configure ${CONFIGURE_ARGS} ${CONFIGURE_X86_64_ARGS}
make  -j$NCPU
cd ..

# Build for arm64

export CC="$(xcrun -f clang) -arch arm64"
export CXX="$(xcrun -f clang++) -arch arm64"
export CFLAGS="-arch arm64"
export LDFLAGS="-arch arm64"

cd build-arm64
../configure ${CONFIGURE_ARGS} ${CONFIGURE_ARM64_ARGS}
make  -j$NCPU
cd ..

cp -v -R build-arm64/. build-universal2

cd build-arm64
for i in `find . -name "*.dylib" -type f`; do
    # echo "$i"
    LIB_NAME=${i##*/}
    LIB_PATH=${i##./}

    echo lipo -create -output ../build-universal2/${LIB_PATH} ../build-arm64/${LIB_PATH} ../build-x86_64/${LIB_PATH}
    lipo -create -output ../build-universal2/${LIB_PATH} ../build-arm64/${LIB_PATH} ../build-x86_64/${LIB_PATH}
done

cd ../build-universal2
sudo make install