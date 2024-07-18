export SOURCE_URL="https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.0.3/libjpeg-turbo-3.0.3.tar.gz"
export CMAKE_ARGS="-DWITH_JPEG8=1 -DCMAKE_EXE_LINKER_FLAGS=-Wl"

source "../common/get_source.sh"
source "../common/cmake_build_lipo.sh"