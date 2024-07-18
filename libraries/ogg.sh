export SOURCE_URL="https://gitlab.xiph.org/xiph/ogg/-/archive/v1.3.5/ogg-v1.3.5.zip"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"