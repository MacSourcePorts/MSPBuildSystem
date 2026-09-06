source "./source_urls.sh"

export SOURCE_URL=${JBIG2DEC_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-silent-rules --without-libpng"

source "../common/get_source.sh"
source "../common/make_build.sh"