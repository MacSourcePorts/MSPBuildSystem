export SOURCE_URL="https://github.com/libass/libass/releases/download/0.17.3/libass-0.17.3.tar.xz"
export CONFIGURE_ARGS="--disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"

sudo install_name_tool -id "@rpath/libass.9.dylib" /usr/local/lib/libass.9.dylib
