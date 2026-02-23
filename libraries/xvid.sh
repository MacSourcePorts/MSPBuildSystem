source "./source_urls.sh"

export SOURCE_URL=${XVID_URL}
export SOURCE_FOLDER="xvidcore/build/generic"
export CONFIGURE_ARGS="--disable-assembly"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libxvidcore.4.dylib" /usr/local/lib/libxvidcore.4.dylib