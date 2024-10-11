export SOURCE_URL="https://github.com/libsdl-org/SDL_mixer/releases/download/release-2.8.0/SDL2_mixer-2.8.0.zip"
export CONFIGURE_ARGS="--enable-music-wave --enable-music-mod --enable-music-mod-xmp --disable-music-mod-xmp-shared --enable-music-mod-modplug --disable-music-mod-modplug-shared --enable-music-midi --enable-music-midi-fluidsynth --disable-music-midi-fluidsynth-shared --disable-music-midi-native --disable-music-midi-timidity --enable-music-ogg --enable-music-ogg-vorbis --disable-music-ogg-vorbis-shared --disable-music-ogg-stb --disable-music-ogg-tremor --enable-music-flac --enable-music-flac-libflac --disable-music-flac-libflac-shared --disable-music-flac-drflac --enable-music-mp3 --enable-music-mp3-mpg123 --disable-music-mp3-mpg123-shared --disable-music-mp3-minimp3 --enable-music-opus --disable-music-opus-shared --enable-music-gme --disable-music-gme-shared --enable-music-wavpack --enable-music-wavpack-dsd --disable-music-wavpack-shared"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libSDL2_mixer-2.0.0.dylib" /usr/local/lib/libSDL2_mixer-2.0.0.dylib