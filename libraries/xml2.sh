export SOURCE_URL="https://download.gnome.org/sources/libxml2/2.12/libxml2-2.12.8.tar.xz"
export MAKE_ARGS="--disable-silent-rules --with-history --with-icu --without-python --without-lzma"

source "../common/get_source.sh"
source "../common/make_build.sh"