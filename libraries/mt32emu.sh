export SOURCE_URL="https://github.com/munt/munt/archive/refs/tags/libmt32emu_2_7_2.tar.gz"
export SOURCE_FILE="munt-libmt32emu_2_7_2.tar.gz"
export CMAKE_ARGS="-Dmunt_WITH_MT32EMU_QT=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"