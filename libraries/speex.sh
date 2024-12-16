export SOURCE_URL="https://downloads.xiph.org/releases/speex/speex-1.2.1.tar.gz"
export CONFIGURE_ARGS=""

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libspeex.1.dylib" /usr/local/lib/libspeex.1.dylib
