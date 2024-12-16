# NOTE: Has an issue when installing, but libicu dylibs are stll installed. 
# Unsure if this is going to be an issue but moving on for now.

export SOURCE_URL="https://github.com/unicode-org/icu/releases/download/release-74-2/icu4c-74_2-src.tgz"
export SOURCE_FOLDER="icu/source"
export CONFIGURE_ARGS="--disable-samples --disable-tests --enable-static --with-library-bits=64"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libicudata.74.2.dylib" /usr/local/lib/libicudata.74.2.dylib
sudo install_name_tool -id "@rpath/libicui18n.74.2.dylib" /usr/local/lib/libicui18n.74.2.dylib
sudo install_name_tool -id "@rpath/libicuio.74.2.dylib" /usr/local/lib/libicuio.74.2.dylib
sudo install_name_tool -id "@rpath/libicutest.74.2.dylib" /usr/local/lib/libicutest.74.2.dylib
sudo install_name_tool -id "@rpath/libicutu.74.2.dylib" /usr/local/lib/libicutu.74.2.dylib
sudo install_name_tool -id "@rpath/libicuuc.74.2.dylib" /usr/local/lib/libicuuc.74.2.dylib

sudo install_name_tool -change libicudata.74.dylib @rpath/libicudata.74.2.dylib /usr/local/lib/libicuuc.74.2.dylib
sudo install_name_tool -change libicutu.74.dylib @rpath/libicutu.74.2.dylib /usr/local/lib/libicutest.74.2.dylib
sudo install_name_tool -change libicudata.74.dylib @rpath/libicudata.74.2.dylib /usr/local/lib/libicutest.74.2.dylib
sudo install_name_tool -change libicuuc.74.dylib @rpath/libicuuc.74.2.dylib /usr/local/lib/libicutest.74.2.dylib
sudo install_name_tool -change libicudata.74.dylib @rpath/libicudata.74.2.dylib /usr/local/lib/libicutest.74.2.dylib
sudo install_name_tool -change libicui18n.74.dylib @rpath/libicui18n.74.dylib /usr/local/lib/libicutest.74.2.dylib
sudo install_name_tool -change libicuuc.74.dylib @rpath/libicuuc.74.2.dylib /usr/local/lib/libicuio.74.2.dylib
sudo install_name_tool -change libicudata.74.dylib @rpath/libicudata.74.2.dylib /usr/local/lib/libicuio.74.2.dylib
sudo install_name_tool -change libicui18n.74.dylib @rpath/libicui18n.74.2.dylib /usr/local/lib/libicuio.74.2.dylib
sudo install_name_tool -change libicuuc.74.dylib @rpath/libicuuc.74.2.dylib /usr/local/lib/libicutu.74.2.dylib
sudo install_name_tool -change libicudata.74.dylib @rpath/libicudata.74.2.dylib /usr/local/lib/libicutu.74.2.dylib
sudo install_name_tool -change libicui18n.74.dylib @rpath/libicui18n.74.2.dylib /usr/local/lib/libicutu.74.2.dylib
sudo install_name_tool -change libicuuc.74.dylib @rpath/libicuuc.74.2.dylib /usr/local/lib/libicui18n.74.2.dylib
sudo install_name_tool -change libicudata.74.dylib @rpath/libicudata.74.2.dylib /usr/local/lib/libicui18n.74.2.dylib