export SOURCE_URL="https://gitlab.xiph.org/xiph/opusfile/-/archive/v0.12/opusfile-v0.12.tar.gz"
export MAKE_ARGS="--disable-http --disable-static --enable-shared --disable-doc"

source "../common/get_source.sh"
source "../common/make_build.sh"