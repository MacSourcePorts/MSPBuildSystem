source "./source_urls.sh"

export SOURCE_URL=${OPENJPEG_URL}
export CMAKE_ARGS="-DBUILD_DOC=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"