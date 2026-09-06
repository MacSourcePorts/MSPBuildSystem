source "./source_urls.sh"

export SOURCE_URL=${XTRANS_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-silent-rules --enable-docs=no"

source "../common/get_source.sh"
source "../common/make_build.sh"