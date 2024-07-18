export SOURCE_URL="https://downloads.sourceforge.net/project/xmp/libxmp/4.6.0/libxmp-4.6.0.tar.gz"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"