export SOURCE_URL="https://github.com/FluidSynth/fluidsynth/archive/refs/tags/v2.3.5.zip"
export SOURCE_FILE="fluidsynth-2.3.5.zip"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -Denable-framework=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"