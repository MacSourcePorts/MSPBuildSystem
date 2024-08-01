export SOURCE_URL="https://github.com/facebook/zstd/archive/refs/tags/v1.5.6.tar.gz"
export SOURCE_FILE="zstd-1.5.6.tar.gz"
export SOURCE_FOLDER="zstd-1.5.6/build/cmake"
export CMAKE_ARGS="-DZSTD_PROGRAMS_LINK_SHARED=ON -DZSTD_BUILD_CONTRIB=ON -DZSTD_LEGACY_SUPPORT=ON -DZSTD_ZLIB_SUPPORT=ON -DZSTD_LZMA_SUPPORT=ON -DZSTD_LZ4_SUPPORT=ON -DCMAKE_CXX_STANDARD=11"

source "../common/get_source.sh"
source "../common/cmake_build.sh"