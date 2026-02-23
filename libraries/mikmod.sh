source "./source_urls.sh"

export SOURCE_URL=${MIKMOD_URL}

export CONFIGURE_ARGS="--disable-debug --disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libmikmod.3.dylib" /usr/local/lib/libmikmod.3.dylib