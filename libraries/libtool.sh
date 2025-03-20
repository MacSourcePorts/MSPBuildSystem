export SOURCE_URL="https://ftp.gnu.org/gnu/libtool/libtool-2.5.4.tar.xz"
export CONFIGURE_ARGS="--prefix=/usr/local --disable-dependency-tracking --disable-silent-rules --enable-ltdl-install"
export SED="sed"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"