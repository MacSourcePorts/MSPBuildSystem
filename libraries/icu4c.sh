export SOURCE_URL="https://github.com/unicode-org/icu/releases/download/release-74-2/icu4c-74_2-src.tgz"
export SOURCE_FOLDER="icu/source"
export CONFIGURE_ARGS="--disable-samples --disable-tests --enable-static --with-library-bits=64"

source "../common/get_source.sh"
source "../common/make_build.sh"