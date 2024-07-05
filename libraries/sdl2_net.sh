export SOURCE_URL="https://github.com/libsdl-org/SDL_net/releases/download/release-2.2.0/SDL2_net-2.2.0.zip"
export MAKE_ARGS="--disable-dependency-tracking --disable-sdltest"

"../common/make_build.sh"

sudo install_name_tool -id "@rpath/libSDL2_net-2.0.0.dylib" /usr/local/lib/libSDL2_net-2.0.0.dylib
