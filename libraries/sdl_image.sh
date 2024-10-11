export CONFIGURE_ARGS="--disable-dependency-tracking --disable-imageio --disable-jpg-shared --disable-png-shared --disable-sdltest --disable-tif-shared --disable-webp-shared"
export SOURCE_FOLDER="SDL_image"

rm -rf source
mkdir source
cd source
git clone https://github.com/libsdl-org/SDL_image.git
cd SDL_image
git switch SDL-1.2
cd ../..

source "../common/make_build.sh"
sudo install_name_tool -id "@rpath/libSDL_image-1.2.0.dylib" /usr/local/lib/libSDL_image-1.2.0.dylib