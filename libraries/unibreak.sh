export SOURCE_URL="https://github.com/adah1972/libunibreak/releases/download/libunibreak_6_1/libunibreak-6.1.tar.gz"
export CONFIGURE_ARGS="--disable-silent-rules"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libunibreak.6.dylib" /usr/local/lib/libunibreak.6.dylib
