export SOURCE_URL="https://github.com/tukaani-project/xz/releases/download/v5.4.6/xz-5.4.6.tar.gz"
export CONFIGURE_ARGS="--disable-silent-rules --disable-nls --enable-static"

source "../common/get_source.sh"
source "../common/make_build.sh"