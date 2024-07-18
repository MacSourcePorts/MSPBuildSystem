export SOURCE_URL="https://github.com/google/brotli/archive/refs/tags/v1.1.0.tar.gz"
export SOURCE_FILE="brotli-1.1.0.tar.gz"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"