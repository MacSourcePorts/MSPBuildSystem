# NOTE: Has an issue when installing, but libtasn dylibs are stll installed. 
# Unsure if this is going to be an issue but moving on for now.

source "./source_urls.sh"

export SOURCE_URL=${TASN1_URL}
export CONFIGURE_ARGS="--disable-silent-rules --disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libtasn1.6.dylib" /usr/local/lib/libtasn1.6.dylib