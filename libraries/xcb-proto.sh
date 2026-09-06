source "./source_urls.sh"

export SOURCE_URL=${XCBPROTO_URL}
export CONFIGURE_ARGS="--disable-silent-rules"

source "../common/get_source.sh"
source "../common/make_build.sh"