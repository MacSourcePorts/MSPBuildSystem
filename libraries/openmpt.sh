source "./source_urls.sh"

export SOURCE_URL="https://lib.openmpt.org/files/libopenmpt/src/libopenmpt-0.8.4+release.autotools.tar.gz"
export CONFIGURE_ARGS="--disable-silent-rules"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libopenmpt.0.dylib" /usr/local/lib/libopenmpt.0.dylib