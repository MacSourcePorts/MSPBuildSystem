source "./source_urls.sh"

export SOURCE_URL=${EXPAT_URL}
export CONFIGURE_ARGS=""

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -change /usr/local/lib/libexpat.1.dylib @rpath/libexpat.1.dylib /usr/local/lib/libexpat.1.9.2.dylib