source "./source_urls.sh"

export SOURCE_URL=${JPEGTURBO_URL}
export CMAKE_ARGS="-DWITH_JPEG8=1 -DCMAKE_EXE_LINKER_FLAGS=-Wl"

source "../common/get_source.sh"
source "../common/cmake_build_lipo.sh"