export SOURCE_URL="https://downloads.xiph.org/releases/vorbis/libvorbis-1.3.7.tar.xz"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"