export SOURCE_URL="https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-1.0.1.tar.gz"
export MAKE_ARGS="--disable-dependency-tracking --disable-silent-rules --enable-https"

source "../common/get_source.sh"
source "../common/make_build.sh"