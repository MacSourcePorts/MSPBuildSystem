export SOURCE_URL="https://github.com/DaveGamble/cJSON/archive/refs/tags/v1.7.18.tar.gz"
export SOURCE_FILE="cJSON-1.7.18.tar.gz"
export CMAKE_ARGS="-DENABLE_CJSON_UTILS=ON -DENABLE_CJSON_TEST=Off -DBUILD_SHARED_AND_STATIC_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"