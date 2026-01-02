export SOURCE_URL="https://github.com/libexpat/libexpat/releases/download/R_2_6_2/expat-2.6.2.tar.lz"
export CONFIGURE_ARGS=""

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -change /usr/local/lib/libexpat.1.dylib @rpath/libexpat.1.dylib /usr/local/lib/libexpat.1.9.2.dylib