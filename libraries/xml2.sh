source "./source_urls.sh"

export SOURCE_URL=${XML2_URL}
export CONFIGURE_ARGS="--disable-silent-rules --with-history --with-icu --without-python --without-lzma"

source "../common/get_source.sh"
source "../common/make_build.sh"