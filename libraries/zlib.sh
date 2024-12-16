export SOURCE_URL="https://zlib.net/zlib-1.3.1.tar.gz"
export CONFIGURE_ARGS=""

source "../common/get_source.sh"
export CFLAGS="-arch arm64 -arch x86_64"
export LDFLAGS="-arch arm64 -arch x86_64"
source "../common/make_build2.sh"

sudo install_name_tool -id "@rpath/libz.1.dylib" /usr/local/lib/libz.1.dylib