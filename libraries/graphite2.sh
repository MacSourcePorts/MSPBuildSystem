export SOURCE_URL="https://github.com/silnrsi/graphite/releases/download/1.3.14/graphite2-1.3.14.tgz"
export SOURCE_FOLDER="graphite2-1.3.14"
export CMAKE_ARGS=""

source "../common/get_source.sh"
source "../common/cmake_build.sh"

sudo install_name_tool -id "@rpath/libgraphite2.3.dylib" /usr/local/lib/libgraphite2.3.dylib