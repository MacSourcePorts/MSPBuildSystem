source "./source_urls.sh"

export SOURCE_URL=${FFI_URL}
export CONFIGURE_ARGS="--disable-static"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"