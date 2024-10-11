export CONFIGURE_ARGS="--disable-dependency-tracking --enable-music-ogg --enable-music-flac --disable-music-ogg-shared --disable-music-mod-shared --enable-music-mod"
export SOURCE_FOLDER="SDL_mixer"

rm -rf source
mkdir source
cd source
git clone https://github.com/libsdl-org/SDL_mixer.git
cd SDL_mixer
git switch SDL-1.2
cd ../..

source "../common/make_build.sh"
sudo install_name_tool -id "@rpath/libSDL_mixer-1.2.0.dylib" /usr/local/lib/libSDL_mixer-1.2.0.dylib