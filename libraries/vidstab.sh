export SOURCE_URL="https://github.com/georgmartius/vid.stab/archive/refs/tags/v1.1.1.tar.gz"
export SOURCE_FILE="vid.stab-1.1.1.tar.gz"
export CMAKE_ARGS="-DUSE_OMP=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"