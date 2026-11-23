source "./source_urls.sh"

export SOURCE_URL=${TIFF_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-webp --enable-zstd --enable-lzma --without-x"

source "../common/get_source.sh"
source "../common/make_build.sh"

# autotools installs with absolute install names; use @rpath like the other
# libraries so anything linked against libtiff (DevIL etc.) can be bundled
sudo install_name_tool -id "@rpath/libtiff.6.dylib" /usr/local/lib/libtiff.6.dylib
sudo install_name_tool -id "@rpath/libtiffxx.6.dylib" /usr/local/lib/libtiffxx.6.dylib
sudo install_name_tool -change "/usr/local/lib/libtiff.6.dylib" "@rpath/libtiff.6.dylib" /usr/local/lib/libtiffxx.6.dylib
