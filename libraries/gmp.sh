export SOURCE_URL="https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz"
export CONFIGURE_ARGS="--enable-cxx --with-pic"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"

sudo install_name_tool -id "@rpath/libgmpxx.4.dylib" /usr/local/lib/libgmpxx.4.dylib
sudo install_name_tool -id "@rpath/libgmp.10.dylib" /usr/local/lib/libgmp.10.dylib