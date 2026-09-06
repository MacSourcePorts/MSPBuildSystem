source "./source_urls.sh"

export SOURCE_URL=${GLEW_URL}
export CMAKE_ARGS=""

source "../common/get_source.sh"
export SOURCE_FOLDER="${SOURCE_FOLDER}/build/cmake"
source "../common/cmake_build.sh"