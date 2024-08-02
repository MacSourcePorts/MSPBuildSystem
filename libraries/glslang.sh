export SOURCE_URL="https://github.com/KhronosGroup/glslang/archive/refs/tags/14.3.0.tar.gz"
export SOURCE_FILE="glslang-14.3.0.tar.gz "
export CMAKE_ARGS="-DBUILD_EXTERNAL=OFF -DALLOW_EXTERNAL_SPIRV_TOOLS=ON -DBUILD_SHARED_LIBS=ON -DENABLE_CTEST=OFF -DENABLE_OPT=ON"
export MACOSX_DEPLOYMENT_TARGET="10.15"

source "../common/get_source.sh"
source "../common/cmake_build.sh"