export SOURCE_URL="https://github.com/libevent/libevent/archive/refs/tags/release-2.1.12-stable.tar.gz"
export SOURCE_FILE="libevent-release-2.1.12-stable.tar.gz"
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-debug-mode"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libevent_pthreads-2.1.7.dylib" /usr/local/lib/libevent_pthreads-2.1.7.dylib
sudo install_name_tool -id "@rpath/libevent_openssl-2.1.7.dylib" /usr/local/lib/libevent_openssl-2.1.7.dylib
sudo install_name_tool -id "@rpath/libevent_extra-2.1.7.dylib" /usr/local/lib/libevent_extra-2.1.7.dylib
sudo install_name_tool -id "@rpath/libevent-2.1.7.dylib" /usr/local/lib/libevent-2.1.7.dylib
sudo install_name_tool -id "@rpath/libevent_core-2.1.7.dylib" /usr/local/lib/libevent_core-2.1.7.dylib