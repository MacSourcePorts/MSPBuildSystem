source "./source_urls.sh"

export SOURCE_URL=${IDN2_URL}
export CONFIGURE_ARGS="--disable-silent-rules"

export RANLIB=/usr/bin/ranlib
export AR=/usr/bin/ar

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libidn2.0.dylib" /usr/local/lib/libidn2.0.dylib