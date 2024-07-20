export SOURCE_URL="https://ftp.gnu.org/gnu/nettle/nettle-3.10.tar.gz"
export MAKE_ARGS="--enable-shared"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"
make check