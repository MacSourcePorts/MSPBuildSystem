export SOURCE_URL="https://download.osgeo.org/libtiff/tiff-4.6.0.tar.gz"
export MAKE_ARGS="--disable-dependency-tracking --disable-webp --enable-zstd --enable-lzma --without-x"

"../common/make_build.sh"