export SOURCE_URL="https://www.mpg123.de/download/mpg123-1.32.6.tar.bz2"
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-static --enable-shared --with-default-audio=coreaudio" 

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"