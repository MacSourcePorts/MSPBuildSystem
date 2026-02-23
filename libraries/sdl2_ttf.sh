source "./source_urls.sh"

export SOURCE_URL=${SDL2_TTF_URL}
export CONFIGURE_ARGS="--disable-freetype-builtin --disable-harfbuzz-builtin --enable-harfbuzz"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libSDL2_ttf-2.0.0.dylib" /usr/local/lib/libSDL2_ttf-2.0.0.dylib