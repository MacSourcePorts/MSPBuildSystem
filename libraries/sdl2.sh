rm -rf source
mkdir source
cd source
curl -JLO https://github.com/libsdl-org/SDL/releases/download/release-2.30.3/SDL2-2.30.3.zip
unzip SDL2-2.30.3.zip

export MACOSX_DEPLOYMENT_TARGET="10.7"

cd ..
rm -rf build
mkdir build
cd build
cmake ../source/SDL2-2.30.3 "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64"
cmake --build .
cmake --install .