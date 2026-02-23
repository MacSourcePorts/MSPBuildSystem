source "./source_urls.sh"

export SOURCE_URL=${AVIF_URL}
export CMAKE_ARGS="-DAVIF_CODEC_AOM=SYSTEM -DAVIF_BUILD_APPS=ON -DAVIF_BUILD_EXAMPLES=OFF -DAVIF_BUILD_TESTS=OFF -DAVIF_LIBYUV=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"