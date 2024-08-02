export SOURCE_URL="https://github.com/g-truc/glm/archive/refs/tags/1.0.1.tar.gz"
export SOURCE_FILE="glm-1.0.1.tar.gz"
export CMAKE_ARGS="-DGLM_BUILD_TESTS=OFF -DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"