export SOURCE_URL="https://github.com/webmproject/libvpx/archive/refs/tags/v1.14.1.zip"
export SOURCE_FILE="libvpx-1.14.1.zip"
export MAKE_ARGS="--disable-static --enable-shared --disable-dependency-tracking --disable-examples --disable-unit-tests --enable-pic --enable-vp9-highbitdepth"

"../common/make_build_lipo2.sh"

sudo install_name_tool -id "@rpath/libvpx.9.dylib" /usr/local/lib/libvpx.9.dylib