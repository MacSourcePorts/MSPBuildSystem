source "./source_urls.sh"

export SOURCE_URL=${TIFF_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-webp --enable-zstd --enable-lzma --without-x"

source "../common/get_source.sh"
source "../common/make_build.sh"