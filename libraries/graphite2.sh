source "./source_urls.sh"

export SOURCE_URL=${GRAPHITE2_URL}
export CMAKE_ARGS=""

source "../common/get_source.sh"
source "../common/cmake_build.sh"

sudo install_name_tool -id "@rpath/libgraphite2.3.dylib" /usr/local/lib/libgraphite2.3.dylib