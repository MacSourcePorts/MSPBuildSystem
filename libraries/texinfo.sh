source "./source_urls.sh"

export SOURCE_URL=${TEXINFO_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-install-warnings"

source "../common/get_source.sh"

sudo install_name_tool -id "/usr/local/lib/libintl.8.dylib" /usr/local/lib/libintl.8.dylib

source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libintl.8.dylib" /usr/local/lib/libintl.8.dylib
