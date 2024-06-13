rm -rf source
mkdir source
cd source
curl -JLO https://github.com/libsdl-org/SDL_net/releases/download/release-2.2.0/SDL2_net-2.2.0.zip
unzip SDL2_net-2.2.0.zip

export MACOSX_DEPLOYMENT_TARGET="10.7"

cd ..
rm -rf build
mkdir build
cd build
cmake ../source/SDL2_net-2.2.0 "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64"
cmake --build .
cmake --install .