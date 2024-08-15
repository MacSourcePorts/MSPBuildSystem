export SOURCE_URL="https://zlib.net/zlib-1.3.1.tar.gz"
export CONFIGURE_ARGS=""

source "../common/get_source.sh"
export CFLAGS="-arch arm64 -arch x86_64"
export LDFLAGS="-arch arm64 -arch x86_64"
source "../common/make_build2.sh"