export SOURCE_URL="https://github.com/lz4/lz4/releases/download/v1.9.4/lz4-1.9.4.tar.gz"
export MAKE_ARGS=""

source "../common/get_source.sh"
source "../common/make_build2.sh"

sudo install_name_tool -id "@rpath/liblz4.1.9.4.dylib" /usr/local/lib/liblz4.1.9.4.dylib