export SOURCE_URL="https://downloads.sourceforge.net/project/lcms/lcms/2.16/lcms2-2.16.tar.gz"
export CONFIGURE_ARGS=""

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/liblcms2.2.dylib" /usr/local/lib/liblcms2.2.dylib