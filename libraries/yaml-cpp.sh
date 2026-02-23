source "./source_urls.sh"

export SOURCE_URL=${YAMLCPP_URL}
export CMAKE_ARGS="-DYAML_BUILD_SHARED_LIBS=ON -DYAML_CPP_BUILD_TESTS=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"