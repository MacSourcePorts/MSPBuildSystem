export SOURCE_URL="https://github.com/libsdl-org/SDL_ttf/releases/download/release-2.22.0/SDL2_ttf-2.22.0.tar.gz"
export CONFIGURE_ARGS="--disable-freetype-builtin --disable-harfbuzz-builtin --enable-harfbuzz"

source "../common/get_source.sh"
source "../common/make_build.sh"