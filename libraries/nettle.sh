# Note: not building at the moment.

export SOURCE_URL="https://ftp.gnu.org/gnu/nettle/nettle-3.10.tar.gz"
export CONFIGURE_ARGS="--enable-shared"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"

sudo install_name_tool -id "@rpath/libhogweed.6.9.dylib" /usr/local/lib/libhogweed.6.9.dylib
sudo install_name_tool -id "@rpath/libnettle.8.9.dylib" /usr/local/lib/libnettle.8.9.dylib
