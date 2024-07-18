export SOURCE_URL="https://github.com/fmtlib/fmt/releases/download/11.0.1/fmt-11.0.1.zip"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"