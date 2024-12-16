export SOURCE_URL="https://download.libsodium.org/libsodium/releases/libsodium-1.0.20.tar.gz"
export CONFIGURE_ARGS="--disable-debug --disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libsodium.26.dylib" /usr/local/lib/libsodium.26.dylib