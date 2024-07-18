export SOURCE_URL="https://downloads.xiph.org/releases/opus/opus-1.5.2.tar.gz"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"