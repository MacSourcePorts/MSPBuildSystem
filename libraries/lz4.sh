source "./source_urls.sh"

export SOURCE_URL=${LZ4_URL}
export CONFIGURE_ARGS=""

source "../common/get_source.sh"
source "../common/make_build2.sh"

sudo install_name_tool -id "@rpath/liblz4.1.9.4.dylib" /usr/local/lib/liblz4.1.9.4.dylib