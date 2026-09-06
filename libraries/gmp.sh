source "./source_urls.sh"

export SOURCE_URL=${GMP_URL}
export CONFIGURE_ARGS="--enable-cxx --with-pic"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"

sudo install_name_tool -id "@rpath/libgmpxx.4.dylib" /usr/local/lib/libgmpxx.4.dylib
sudo install_name_tool -id "@rpath/libgmp.10.dylib" /usr/local/lib/libgmp.10.dylib

sudo install_name_tool -change /usr/local/lib/libgmp.10.dylib @rpath/libgmp.10.dylib /usr/local/lib/libgmpxx.4.dylib