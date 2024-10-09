export MACOSX_DEPLOYMENT_TARGET="10.7"
export NCPU=`sysctl -n hw.ncpu`

rm -rf build
mkdir -p build/build_x86_64
mkdir -p build/build_arm64
mkdir -p build/build_universal2

rm -rf source
mkdir source
cd source

curl -JLO https://www.openssl.org/source/openssl-3.0.0.tar.gz
tar -xzvf openssl-3.0.0.tar.gz
cd openssl-3.0.0

mkdir build_x86_64
cd build_x86_64
../Configure darwin64-x86_64-cc --prefix=/Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/build/build_x86_64
make -j$NCPU
make install
cd ..

mkdir build_arm64
cd build_arm64
../Configure darwin64-arm64-cc --prefix=/Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/build/build_arm64
make -j$NCPU
make install
cd ..

cd ../../build

cp -v -R build_arm64/. build_universal2
cd build_arm64
for i in `find . -name "*.dylib" -type f`; do
    # echo "$i"
    LIB_NAME=${i##*/}
    LIB_PATH=${i##./}

    echo lipo -create -output ../build_universal2/${LIB_PATH} ../build_arm64/${LIB_PATH} ../build_x86_64/${LIB_PATH}
    lipo -create -output ../build_universal2/${LIB_PATH} ../build_arm64/${LIB_PATH} ../build_x86_64/${LIB_PATH}
done
cd ..
sudo cp -v -R build_universal2/* /usr/local/