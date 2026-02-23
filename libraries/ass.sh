source "./source_urls.sh"

export SOURCE_URL=${ASS_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"

sudo install_name_tool -id "@rpath/libass.9.dylib" /usr/local/lib/libass.9.dylib