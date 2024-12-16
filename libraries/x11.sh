export SOURCE_URL="https://www.x.org/archive/individual/lib/libX11-1.8.9.tar.gz"
export CONFIGURE_ARGS="--disable-silent-rules --enable-unix-transport --enable-tcp-transport --enable-ipv6 --enable-loadable-i18n --enable-xthreads --enable-specs=no"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libX11.6.dylib" /usr/local/lib/libX11.6.dylib
sudo install_name_tool -id "@rpath/libX11-xcb.1.dylib" /usr/local/lib/libX11-xcb.1.dylib