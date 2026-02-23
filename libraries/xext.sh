source "./source_urls.sh"

export SOURCE_URL=${XEXT_URL}
export CONFIGURE_ARGS="--disable-silent-rules --disable-silent-rules --enable-specs=no"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libXext.6.dylib" /usr/local/lib/libXext.6.dylib