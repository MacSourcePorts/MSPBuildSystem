source "./source_urls.sh"

export SOURCE_URL=${OPENCOREAMR_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libopencore-amrnb.0.dylib" /usr/local/lib/libopencore-amrnb.0.dylib
sudo install_name_tool -id "@rpath/libopencore-amrwb.0.dylib" /usr/local/lib/libopencore-amrwb.0.dylib