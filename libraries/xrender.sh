source "./source_urls.sh"

export SOURCE_URL=${XRENDER_URL}
export CONFIGURE_ARGS="--disable-silent-rules --disable-silent-rules"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libXrender.1.dylib" /usr/local/lib/libXrender.1.dylib