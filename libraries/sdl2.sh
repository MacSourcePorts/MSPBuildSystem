source "./source_urls.sh"

export SOURCE_URL=${SDL2_URL}
export CMAKE_ARGS=""

source "../common/get_source.sh"
source "../common/cmake_build.sh"