export SOURCE_URL="https://www.wavpack.com/wavpack-5.7.0.tar.bz2"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"