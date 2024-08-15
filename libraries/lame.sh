export SOURCE_URL="https://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz"
export CONFIGURE_ARGS="--disable-static --enable-shared --disable-dependency-tracking --disable-debug --enable-nasm"

source "../common/get_source.sh"
/usr/local/bin/gsed -i '/lame_init_old/d' source/lame-3.100/include/libmp3lame.sym
source "../common/make_build.sh"