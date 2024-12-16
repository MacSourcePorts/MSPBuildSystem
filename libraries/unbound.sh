export SOURCE_URL="https://nlnetlabs.nl/downloads/unbound/unbound-1.20.0.tar.gz"
export CONFIGURE_ARGS="--enable-event-api --enable-tfo-client --enable-tfo-server"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libunbound.8.dylib" /usr/local/lib/libunbound.8.dylib