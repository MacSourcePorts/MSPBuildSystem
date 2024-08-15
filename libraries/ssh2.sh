export SOURCE_URL="https://libssh2.org/download/libssh2-1.11.0.tar.gz"
export CONFIGURE_ARGS="--disable-silent-rules --disable-examples-build --with-openssl --with-libz"

source "../common/get_source.sh"
source "../common/make_build.sh"