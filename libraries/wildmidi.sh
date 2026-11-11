source "./source_urls.sh"

export SOURCE_URL=${WILDMIDI_URL}
export CMAKE_ARGS="-DWANT_PLAYER=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"