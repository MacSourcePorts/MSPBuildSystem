source "./source_urls.sh"

export SOURCE_URL=${ZIMG_URL}

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"

sudo install_name_tool -id "@rpath/libzimg.2.dylib" /usr/local/lib/libzimg.2.dylib