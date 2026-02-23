source "./source_urls.sh"

export SOURCE_URL=${CJSON_URL}
export CMAKE_ARGS="-DENABLE_CJSON_UTILS=ON -DENABLE_CJSON_TEST=Off -DBUILD_SHARED_AND_STATIC_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"