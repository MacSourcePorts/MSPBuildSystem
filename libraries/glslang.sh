source "./source_urls.sh"

export SOURCE_URL=${GLSLANG_URL}
export CMAKE_ARGS="-DBUILD_EXTERNAL=OFF -DALLOW_EXTERNAL_SPIRV_TOOLS=ON -DBUILD_SHARED_LIBS=ON -DENABLE_CTEST=OFF -DENABLE_OPT=ON"
export MACOSX_DEPLOYMENT_TARGET="10.15"

source "../common/get_source.sh"
source "../common/cmake_build.sh"

sudo install_name_tool -add_rpath /usr/local/lib/. /usr/local/bin/glslang