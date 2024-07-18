export SOURCE_URL="https://github.com/libffi/libffi/releases/download/v3.4.4/libffi-3.4.4.tar.gz"
export MAKE_ARGS="--disable-static"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"