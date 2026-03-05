export MACOSX_DEPLOYMENT_TARGET="10.13"
export SOURCE_URL="https://github.com/ZDoom/ZMusic/archive/refs/tags/1.3.0.zip"
export CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"

source "../common/get_source.sh"
source "../common/cmake_build.sh"