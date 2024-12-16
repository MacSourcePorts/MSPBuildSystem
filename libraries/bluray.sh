export SOURCE_URL="https://download.videolan.org/videolan/libbluray/1.3.4/libbluray-1.3.4.tar.bz2"
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-silent-rules --disable-bdjava-jar"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libbluray.2.dylib" /usr/local/lib/libbluray.2.dylib