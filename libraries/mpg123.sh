source "./source_urls.sh"

export SOURCE_URL=${MPG123_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-static --enable-shared --with-default-audio=coreaudio" 

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"

sudo install_name_tool -id @rpath/libmpg123.0.dylib /usr/local/lib/libmpg123.0.dylib