export SOURCE_URL="https://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz"
export MAKE_ARGS="--disable-dependency-tracking --enable-shared"

source "../common/get_source.sh"
source "../common/make_build.sh"
# make check