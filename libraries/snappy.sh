source "./source_urls.sh"

export SOURCE_URL=${SNAPPY_URL}
export CMAKE_ARGS="-DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF -DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"