export MACOSX_DEPLOYMENT_TARGET="10.7"
export NCPU=`sysctl -n hw.ncpu`

cd source/${SOURCE_FOLDER}

./autogen.sh

mkdir build-arm64 build-x86_64 build-universal2

# Build for arm64
cd build-arm64
../configure ${MAKE_ARGS} CFLAGS="-arch arm64" LDFLAGS="-arch arm64" --host=aarch64-apple-darwin
make  -j$NCPU
cd ..

# Build for x86_64
cd build-x86_64
../configure ${MAKE_ARGS} CFLAGS="-arch x86_64" LDFLAGS="-arch x86_64" --host=x86_64-apple-darwin
make  -j$NCPU
cd ..

cp -r build-arm64/. build-universal2

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