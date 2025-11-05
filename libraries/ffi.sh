export SOURCE_URL="https://github.com/libffi/libffi/releases/download/v3.5.2/libffi-3.5.2.tar.gz"
export CONFIGURE_ARGS="--disable-static"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"