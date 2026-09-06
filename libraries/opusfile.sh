source "./source_urls.sh"

export SOURCE_URL=${OPUSFILE_URL}
export CONFIGURE_ARGS="--disable-http --disable-static --enable-shared --disable-doc"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libopusfile.0.dylib" /usr/local/lib/libopusfile.0.dylib
sudo install_name_tool -id "@rpath/libopusurl.0.dylib" /usr/local/lib/libopusurl.0.dylib
sudo install_name_tool -change /usr/local/lib/libopusfile.0.dylib @rpath/libopusfile.0.dylib /usr/local/lib/libopusurl.0.dylib