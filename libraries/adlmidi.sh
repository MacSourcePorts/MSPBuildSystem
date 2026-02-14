export SOURCE_URL="https://github.com/Wohlstand/libADLMIDI/archive/refs/tags/v1.6.1.zip"
export SOURCE_FILE="libADLMIDI-1.6.1.zip"
export CMAKE_ARGS="-DlibADLMIDI_SHARED=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"