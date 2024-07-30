export SOURCE_URL="https://github.com/zeromq/libzmq/releases/download/v4.3.5/zeromq-4.3.5.tar.gz"
export MAKE_ARGS="--disable-dependency-tracking --with-libsodium"

source "../common/get_source.sh"
source "../common/make_build.sh"