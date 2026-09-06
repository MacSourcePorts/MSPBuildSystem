source "./source_urls.sh"

export SOURCE_URL=${ARIBB24_URL}
export CONFIGURE_ARGS="--disable-silent-rules"

export LDFLAGS="-L/usr/lib/libz.1.dylib"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libaribb24.0.dylib" /usr/local/lib/libaribb24.0.dylib