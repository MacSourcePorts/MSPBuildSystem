source "./source_urls.sh"

export SOURCE_URL=${NGHTTP2_URL}
export CONFIGURE_ARGS="--enable-lib-only"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libnghttp2.14.dylib" /usr/local/lib/libnghttp2.14.dylib