source "./source_urls.sh"

export SOURCE_URL=${LAME_URL}
export CONFIGURE_ARGS="--disable-static --enable-shared --disable-dependency-tracking --disable-debug --enable-nasm"

source "../common/get_source.sh"
/usr/local/bin/gsed -i '/lame_init_old/d' source/${SOURCE_FOLDER}/include/libmp3lame.sym
source "../common/make_build.sh"