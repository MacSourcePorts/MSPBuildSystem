export SOURCE_URL="https://github.com/jbeder/yaml-cpp/archive/refs/tags/0.8.0.tar.gz"
export SOURCE_FILE="yaml-cpp-0.8.0.tar.gz"
export CMAKE_ARGS="-DYAML_BUILD_SHARED_LIBS=ON -DYAML_CPP_BUILD_TESTS=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"