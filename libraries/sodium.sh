source "./source_urls.sh"

export SOURCE_URL=${SODIUM_URL}
export CONFIGURE_ARGS="--disable-debug --disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libsodium.26.dylib" /usr/local/lib/libsodium.26.dylib