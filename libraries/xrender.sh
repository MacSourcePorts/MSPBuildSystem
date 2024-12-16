export SOURCE_URL="https://www.x.org/archive/individual/lib/libXrender-0.9.11.tar.gz"
export CONFIGURE_ARGS="--disable-silent-rules --disable-silent-rules"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libXrender.1.dylib" /usr/local/lib/libXrender.1.dylib