rm -rf source
mkdir source
cd source
curl -JLO https://gitlab.xiph.org/xiph/ogg/-/archive/v1.3.5/ogg-v1.3.5.zip
unzip ogg-v1.3.5.zip

export MACOSX_DEPLOYMENT_TARGET="10.7"

cd ..
rm -rf build
mkdir build
cd build
cmake ../source/ogg-v1.3.5 "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" -DBUILD_SHARED_LIBS=ON
cmake --build .
cmake --install .