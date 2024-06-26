rm -rf source
mkdir source
cd source
curl -JLO https://github.com/libsdl-org/SDL_mixer/releases/download/release-2.8.0/SDL2_mixer-2.8.0.zip
unzip SDL2_mixer-2.8.0.zip
cd SDL2_mixer-2.8.0
./external/download.sh

export MACOSX_DEPLOYMENT_TARGET="10.7"

cd ../..
rm -rf build
mkdir build
cd build

mkdir ogg
cd ogg
cmake ../../source/SDL2_mixer-2.8.0/external/ogg "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" -DBUILD_SHARED_LIBS=ON
cmake --build .
cmake --install .
cd ..

mkdir flac
cd flac
cmake ../../source/SDL2_mixer-2.8.0/external/flac "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" -DOGG_INCLUDE_DIR=../../source/SDL2_mixer-2.8.0/external/ogg/include/ 
cmake --build .
cd ..

mkdir opus
cd opus
cmake ../../source/SDL2_mixer-2.8.0/external/opus "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64"
cmake --build .
cmake --install .
cd ..

mkdir opusfile
cd opusfile
cmake ../../source/SDL2_mixer-2.8.0/external/opusfile "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" -DOP_DISABLE_HTTP=ON -DOP_DISABLE_DOCS=ON
cmake --build .
cmake --install .
cd ..

cmake ../source/SDL2_mixer-2.8.0 "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64"
cmake --build .
cmake --install .

cmake ../../source/SDL2_mixer-2.8.0/external/flac "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" "-DOGG_INCLUDE_DIR=/Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/build/ogg/include/ogg" 


