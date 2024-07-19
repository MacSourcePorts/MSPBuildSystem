export SOURCE_URL="https://code.videolan.org/jeeb/aribb24/-/archive/v1.0.4/aribb24-v1.0.4.tar.bz2"
export MAKE_ARGS="--disable-silent-rules"

# export CFLAGS="-I/usr/local/libz/include"
export LDFLAGS="-L/usr/lib/libz.1.dylib"

source "../common/get_source.sh"
source "../common/make_build.sh"