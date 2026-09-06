source "./source_urls.sh"

export SOURCE_URL=${SDL_GFX_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-sdltest"
export CONFIGURE_ARM64_ARGS="--disable-mmx"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"

sudo install_name_tool -id "@rpath/libSDL_gfx.16.dylib" /usr/local/lib/libSDL_gfx.16.dylib