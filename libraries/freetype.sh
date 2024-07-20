export SOURCE_URL="https://downloads.sourceforge.net/project/freetype/freetype2/2.13.2/freetype-2.13.2.tar.xz"
export MAKE_ARGS="--enable-freetype-config --without-harfbuzz"

source "../common/get_source.sh"
source "../common/make_build.sh"