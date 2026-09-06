source "./source_urls.sh"

export SOURCE_URL=${LITTLECMS2_URL}
export CONFIGURE_ARGS=""

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/liblcms2.2.dylib" /usr/local/lib/liblcms2.2.dylib