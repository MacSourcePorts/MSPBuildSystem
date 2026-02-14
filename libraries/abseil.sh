export MACOSX_DEPLOYMENT_TARGET="10.13"
export SOURCE_URL="https://github.com/abseil/abseil-cpp/archive/refs/tags/20250814.1.tar.gz"
export SOURCE_FILE="abseil-cpp-20250814.1.tar.gz"
export CMAKE_ARGS="-DCMAKE_CXX_STANDARD=17 -DBUILD_SHARED_LIBS=ON -DABSL_PROPAGATE_CXX_STD=ON -DABSL_ENABLE_INSTALL=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"