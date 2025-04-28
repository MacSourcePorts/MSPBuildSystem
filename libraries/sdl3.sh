export SOURCE_URL="https://github.com/libsdl-org/SDL/releases/download/release-3.2.10/SDL3-3.2.10.tar.gz"
export CMAKE_ARGS=""
export MACOSX_DEPLOYMENT_TARGET="10.14"
# export SOURCE_FOLDER="SDL"

# rm -rf source
# mkdir source
# cd source
# git clone --depth 1 https://github.com/libsdl-org/SDL
# cd ..

source "../common/get_source.sh"
source "../common/cmake_build.sh"