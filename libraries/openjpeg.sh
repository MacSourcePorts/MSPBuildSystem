export SOURCE_URL="https://github.com/uclouvain/openjpeg/archive/refs/tags/v2.5.2.tar.gz"
export SOURCE_FILE="openjpeg-2.5.2.tar.gz"
export CMAKE_ARGS="-DBUILD_DOC=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"