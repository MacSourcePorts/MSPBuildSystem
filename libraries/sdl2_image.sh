export SOURCE_URL="https://github.com/libsdl-org/SDL_image/releases/download/release-2.8.2/SDL2_image-2.8.2.tar.gz"
export CONFIGURE_ARGS="--disable-imageio --disable-avif-shared --disable-jpg-shared --disable-jxl-shared --disable-png-shared --disable-stb-image --disable-tif-shared --disable-webp-shared"

source "../common/get_source.sh"
source "../common/make_build.sh"