source "./source_urls.sh"

export SOURCE_URL=${JANSSON_URL}

export RANLIB=/usr/bin/ranlib
export AR=/usr/bin/ar

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libjansson.4.dylib" /usr/local/lib/libjansson.4.dylib