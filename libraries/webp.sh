export SOURCE_URL="https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.4.0.tar.gz"
# export SOURCE_FILE="brotli-1.1.0.tar.gz"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON"

"../common/cmake_build_lipo.sh"