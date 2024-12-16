export SOURCE_URL="https://downloads.sourceforge.net/project/freetype/freetype2/2.13.2/freetype-2.13.2.tar.xz"
export CONFIGURE_ARGS="--enable-freetype-config --without-harfbuzz"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libfreetype.6.dylib" /usr/local/lib/libfreetype.6.dylib
