export SOURCE_URL="https://github.com/KhronosGroup/SPIRV-Tools/archive/refs/tags/vulkan-sdk-1.3.290.0.tar.gz"
export SOURCE_FILE="SPIRV-Tools-vulkan-sdk-1.3.290.0.tar.gz "
export CMAKE_ARGS="-DSPIRV_SKIP_TESTS=ON -DBUILD_SHARED_LIBS=ON -DSPIRV_TOOLS_BUILD_STATIC=OFF"
export MACOSX_DEPLOYMENT_TARGET="10.15"

source "../common/get_source.sh"

cd source/${SOURCE_FOLDER}/external
git clone https://github.com/KhronosGroup/SPIRV-Headers.git
cd SPIRV-Headers
git checkout 2acb319af38d43be3ea76bfabf3998e5281d8d12
cd ../../../..

source "../common/cmake_build.sh"