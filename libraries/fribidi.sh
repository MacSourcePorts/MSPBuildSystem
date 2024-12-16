export SOURCE_URL="https://github.com/fribidi/fribidi/releases/download/v1.0.15/fribidi-1.0.15.tar.xz"
export CONFIGURE_ARGS="-disable-debug --disable-dependency-tracking --disable-silent-rules --enable-static"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libfribidi.0.dylib" /usr/local/lib/libfribidi.0.dylib
