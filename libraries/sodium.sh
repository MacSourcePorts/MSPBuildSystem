export SOURCE_URL="https://download.libsodium.org/libsodium/releases/libsodium-1.0.20.tar.gz"
# export SOURCE_FOLDER="xvidcore/build/generic"
export MAKE_ARGS="--disable-debug --disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build.sh"