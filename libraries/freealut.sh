source "./source_urls.sh"

export SOURCE_URL=${FREEALUT_URL}
export SOURCE_FOLDER="freealut-1.1.0"
export CONFIGURE_ARGS="--disable-debug --disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libalut.0.dylib" /usr/local/lib/libalut.0.dylib