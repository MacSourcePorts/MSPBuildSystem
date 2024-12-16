export SOURCE_URL="https://downloads.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-0.1.6.tar.gz"
export CONFIGURE_ARGS="--disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libopencore-amrnb.0.dylib" /usr/local/lib/libopencore-amrnb.0.dylib
sudo install_name_tool -id "@rpath/libopencore-amrwb.0.dylib" /usr/local/lib/libopencore-amrwb.0.dylib
