export SOURCE_URL="https://github.com/AOMediaCodec/libavif/archive/refs/tags/v1.1.1.tar.gz"
export SOURCE_FILE="libavif-1.1.1.tar.gz"
export CMAKE_ARGS="-DAVIF_CODEC_AOM=SYSTEM -DAVIF_BUILD_APPS=ON -DAVIF_BUILD_EXAMPLES=OFF -DAVIF_BUILD_TESTS=OFF -DAVIF_LIBYUV=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"