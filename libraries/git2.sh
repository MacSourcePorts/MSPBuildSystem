source "./source_urls.sh"

export SOURCE_URL=${GIT2_URL}
export CMAKE_ARGS="-DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF -DUSE_SSH=ON -DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"