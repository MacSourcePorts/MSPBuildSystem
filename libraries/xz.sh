source "./source_urls.sh"

export SOURCE_URL=${XZ_URL}
export CONFIGURE_ARGS="--disable-silent-rules --disable-nls --enable-static"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/liblzma.5.dylib" /usr/local/lib/liblzma.5.dylib