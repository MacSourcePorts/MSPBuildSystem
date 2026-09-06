source "./source_urls.sh"

export SOURCE_URL=${XORGPROTO_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-silent-rules"

source "../common/get_source.sh"
source "../common/make_build.sh"