source "./source_urls.sh"

export SOURCE_URL=${ZEROMQ_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --with-libsodium"

source "../common/get_source.sh"
source "../common/make_build.sh"