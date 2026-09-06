source "./source_urls.sh"

export SOURCE_URL=${UNIBREAK_URL}
export CONFIGURE_ARGS="--disable-silent-rules"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libunibreak.6.dylib" /usr/local/lib/libunibreak.6.dylib