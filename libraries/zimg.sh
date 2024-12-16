export SOURCE_URL="https://github.com/sekrit-twc/zimg/archive/refs/tags/release-3.0.5.tar.gz"
export SOURCE_FILE="zimg-release-3.0.5.tar.gz"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"

sudo install_name_tool -id "@rpath/libzimg.2.dylib" /usr/local/lib/libzimg.2.dylib