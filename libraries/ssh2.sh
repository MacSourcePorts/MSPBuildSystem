source "./source_urls.sh"

export SOURCE_URL=${SSH2_URL}
export CONFIGURE_ARGS="--disable-silent-rules --disable-examples-build --with-openssl --with-libz"

source "../common/get_source.sh"
source "../common/make_build.sh"