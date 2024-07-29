export SOURCE_URL="https://github.com/libgit2/libgit2/archive/refs/tags/v1.8.1.tar.gz"
export SOURCE_FILE="libgit2-1.8.1.tar.gz"
export CMAKE_ARGS="-DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF -DUSE_SSH=ON -DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"