source "./source_urls.sh"

export SOURCE_URL=${PNG_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-silent-rules"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libpng16.16.dylib" /usr/local/lib/libpng16.16.dylib