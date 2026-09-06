source "./source_urls.sh"

export SOURCE_URL=${MAD_URL}
export SOURCE_FOLDER="libmad"
export CMAKE_ARGS=""

source "../common/get_source.sh"
source "../common/cmake_build.sh"