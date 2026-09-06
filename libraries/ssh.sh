source "./source_urls.sh"

export SOURCE_URL=${SSH2_URL}
export CMAKE_ARGS="-DBUILD_STATIC_LIB=ON -DWITH_SYMBOL_VERSIONING=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"