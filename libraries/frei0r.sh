export SOURCE_URL="https://github.com/dyne/frei0r/archive/refs/tags/v2.3.3.tar.gz"
export SOURCE_FILE="frei0r-2.3.3.tar.gz"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DWITHOUT_OPENCV=ON -DWITHOUT_GAVL=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"