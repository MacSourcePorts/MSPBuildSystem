source "./source_urls.sh"

export SOURCE_URL=${LZO_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --enable-shared"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/liblzo2.2.dylib" /usr/local/lib/liblzo2.2.dylib