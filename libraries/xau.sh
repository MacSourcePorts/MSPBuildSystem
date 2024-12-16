export SOURCE_URL="https://www.x.org/archive/individual/lib/libXau-1.0.11.tar.xz"
export CONFIGURE_ARGS="--disable-silent-rules --disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libXau.6.0.0.dylib" /usr/local/lib/libXau.6.0.0.dylib
