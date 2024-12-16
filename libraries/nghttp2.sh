export SOURCE_URL="https://github.com/nghttp2/nghttp2/releases/download/v1.61.0/nghttp2-1.61.0.tar.gz"
export CONFIGURE_ARGS="--enable-lib-only"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libnghttp2.14.dylib" /usr/local/lib/libnghttp2.14.dylib
