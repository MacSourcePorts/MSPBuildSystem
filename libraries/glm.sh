source "./source_urls.sh"

export SOURCE_URL=${GLM_URL}
export CMAKE_ARGS="-DGLM_BUILD_TESTS=OFF -DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"