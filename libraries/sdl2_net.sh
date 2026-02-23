source "./source_urls.sh"

export SOURCE_URL=${SDL2_NET_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-sdltest"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libSDL2_net-2.0.0.dylib" /usr/local/lib/libSDL2_net-2.0.0.dylib