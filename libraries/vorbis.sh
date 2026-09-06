source "./source_urls.sh"

export SOURCE_URL=${VORBIS_URL}
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"