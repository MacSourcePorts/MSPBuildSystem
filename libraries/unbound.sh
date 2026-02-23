source "./source_urls.sh"

export SOURCE_URL=${UNBOUND_URL}
export CONFIGURE_ARGS="--enable-event-api --enable-tfo-client --enable-tfo-server"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libunbound.8.dylib" /usr/local/lib/libunbound.8.dylib