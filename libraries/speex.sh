source "./source_urls.sh"

export SOURCE_URL=${SPEEX_URL}
export CONFIGURE_ARGS=""

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libspeex.1.dylib" /usr/local/lib/libspeex.1.dylib