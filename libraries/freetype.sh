source "./source_urls.sh"

export SOURCE_URL=${FREETYPE_URL}
export CONFIGURE_ARGS="--enable-freetype-config --without-harfbuzz"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libfreetype.6.dylib" /usr/local/lib/libfreetype.6.dylib