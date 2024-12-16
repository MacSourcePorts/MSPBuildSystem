export SOURCE_URL="https://www.x.org/archive/individual/lib/libXext-1.3.6.tar.gz"
export CONFIGURE_ARGS="--disable-silent-rules --disable-silent-rules --enable-specs=no"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libXext.6.dylib" /usr/local/lib/libXext.6.dylib
