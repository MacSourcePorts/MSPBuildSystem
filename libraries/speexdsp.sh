source "./source_urls.sh"

export SOURCE_URL=${SPEEXDSP_URL}
export CONFIGURE_ARGS="--disable-debug --disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build.sh"