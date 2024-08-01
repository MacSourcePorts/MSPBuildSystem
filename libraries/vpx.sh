export SOURCE_URL="https://github.com/webmproject/libvpx/archive/refs/tags/v1.14.1.zip"
export SOURCE_FILE="libvpx-1.14.1.zip"
export MAKE_ARGS="--disable-static --enable-shared --disable-dependency-tracking --disable-examples --disable-unit-tests --enable-pic --enable-vp9-highbitdepth"
export MAKE_ARM64_ARGS="--target=arm64-darwin23-gcc"
export MAKE_X86_64_ARGS="--target=x86_64-darwin23-gcc"

source "../common/get_source.sh"
source "../common/make_build_lipo2.sh"

sudo install_name_tool -id "@rpath/libvpx.9.dylib" /usr/local/lib/libvpx.9.dylib