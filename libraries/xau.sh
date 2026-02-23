source "./source_urls.sh"

export SOURCE_URL=${XAU_URL}
export CONFIGURE_ARGS="--disable-silent-rules --disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libXau.6.0.0.dylib" /usr/local/lib/libXau.6.0.0.dylib