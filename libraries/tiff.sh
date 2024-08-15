export SOURCE_URL="https://download.osgeo.org/libtiff/tiff-4.6.0.tar.gz"
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-webp --enable-zstd --enable-lzma --without-x"

source "../common/get_source.sh"
source "../common/make_build.sh"