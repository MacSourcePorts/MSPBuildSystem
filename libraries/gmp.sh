export SOURCE_URL="https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz"
export MAKE_ARGS="--enable-cxx --with-pic"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"
# make check