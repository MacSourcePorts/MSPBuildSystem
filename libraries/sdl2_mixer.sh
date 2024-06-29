export SOURCE_URL="https://github.com/libsdl-org/SDL_mixer/releases/download/release-2.8.0/SDL2_mixer-2.8.0.zip"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON"

"../common/cmake_build.sh"

# rm -rf source
# mkdir source
# cd source
# curl -JLO https://github.com/libsdl-org/SDL_mixer/releases/download/release-2.8.0/SDL2_mixer-2.8.0.zip
# unzip SDL2_mixer-2.8.0.zip
# cd SDL2_mixer-2.8.0

# export MACOSX_DEPLOYMENT_TARGET="10.7"

# cd ../..
# rm -rf build
# mkdir build
# cd build

# cmake ../source/SDL2_mixer-2.8.0 "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64"
# cmake --build .
# cmake --install .