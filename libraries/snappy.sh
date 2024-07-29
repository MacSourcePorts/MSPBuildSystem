export SOURCE_URL="https://github.com/google/snappy/archive/refs/tags/1.2.1.tar.gz"
export SOURCE_FILE="snappy-1.2.1.tar.gz"
export CMAKE_ARGS="-DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF -DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"