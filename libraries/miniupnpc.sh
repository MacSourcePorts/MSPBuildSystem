# Note: this one builds but fails to install normally

source "./source_urls.sh"

export MACOSX_DEPLOYMENT_TARGET="10.7"
export SOURCE_URL=${MINIUPNPC_URL}
export SOURCE_FILE="download.php"
export PATH="/usr/bin:$PATH"

source "../common/get_source.sh"

cd source
export SOURCE_FOLDER=$(ls -t | head -n1)
cd ${SOURCE_FOLDER}

mkdir build-arm64 build-x86_64 build-universal2

# Build for arm64
make clean
make CC="clang -arch arm64" \
    CXX="clang++ -arch arm64" \
    CPP="clang -E" CXXCPP="clang -E" \
    INSTALLPREFIX=$PWD/build-arm64 \
    install

# Build for x86_64
make clean
make CC="clang -arch x86_64" \
    CXX="clang++ -arch x86_64" \
    CPP="clang -E" CXXCPP="clang -E" \
    INSTALLPREFIX=$PWD/build-x86_64 \
    install

cp -a build-arm64/. build-universal2

cd build-arm64
for i in `find . -name "*.dylib" -type f`; do
    # echo "$i"
    LIB_NAME=${i##*/}
    LIB_PATH=${i##./}

    echo lipo -create -output ../build-universal2/${LIB_PATH} ../build-arm64/${LIB_PATH} ../build-x86_64/${LIB_PATH}
    lipo -create -output ../build-universal2/${LIB_PATH} ../build-arm64/${LIB_PATH} ../build-x86_64/${LIB_PATH}
    echo install_name_tool -id @rpath/${LIB_NAME} ../build-universal2/${LIB_PATH}
    install_name_tool -id @rpath/${LIB_NAME} ../build-universal2/${LIB_PATH}
done

cd ../build-universal2

sudo cp -v -R include/* /usr/local/include
sudo cp -v -R lib/* /usr/local/lib
sudo cp -v -R share/* /usr/local/share

sudo gsed -i "s|/Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/miniupnpc-2.3.2/build-arm64|/usr/local|" /usr/local/lib/pkgconfig/miniupnpc.pc