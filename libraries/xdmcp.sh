export SOURCE_URL="https://www.x.org/archive/individual/lib/libXdmcp-1.1.5.tar.xz"
export CONFIGURE_ARGS="--disable-silent-rules --disable-silent-rules --enable-docs=no"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libXdmcp.6.dylib" /usr/local/lib/libXdmcp.6.dylib
