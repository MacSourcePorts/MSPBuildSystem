export SOURCE_URL="https://deb.debian.org/debian/pool/main/f/freealut/freealut_1.1.0.orig.tar.gz"
export SOURCE_FOLDER="freealut-1.1.0"
export CONFIGURE_ARGS="--disable-debug --disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build.sh"