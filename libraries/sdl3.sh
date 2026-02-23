source "./source_urls.sh"

export SOURCE_URL=${SDL3_URL}
export CMAKE_ARGS=""
export MACOSX_DEPLOYMENT_TARGET="10.14"

source "../common/get_source.sh"
source "../common/cmake_build.sh"