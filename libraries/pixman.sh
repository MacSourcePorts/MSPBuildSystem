source "./source_urls.sh"

export SOURCE_URL=${PIXMAN_URL}
export CONFIGURE_ARGS="--disable-silent-rules --disable-gtk"

source "../common/get_source.sh"
source "../common/meson_build.sh"

sudo install_name_tool -id "@rpath/libpixman-1.0.42.2.dylib" /usr/local/lib/libpixman-1.0.42.2.dylib