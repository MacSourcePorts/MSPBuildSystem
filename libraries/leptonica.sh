source "./source_urls.sh"

export SOURCE_URL=${LEPTONICA_URL}
export CONFIGURE_ARGS="--with-libwebp --with-libopenjpeg"

source "../common/get_source.sh"
source "../common/make_build.sh"