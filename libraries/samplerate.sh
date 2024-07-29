export SOURCE_URL="https://github.com/libsndfile/libsamplerate/archive/refs/tags/0.2.2.tar.gz"
export SOURCE_FILE="libsamplerate-0.2.2.tar.gz"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DLIBSAMPLERATE_EXAMPLES=OFF -DBUILD_TESTING=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"