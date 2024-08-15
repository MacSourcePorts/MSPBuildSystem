export SOURCE_URL="https://xorg.freedesktop.org/archive/individual/lib/libxcb-1.17.0.tar.xz"
export CONFIGURE_ARGS="--enable-dri3 --enable-ge --enable-xevie --enable-xprint --enable-selinux --disable-silent-rules --enable-devel-docs=no --with-doxygen=no"

source "../common/get_source.sh"
source "../common/make_build.sh"