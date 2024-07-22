export SOURCE_URL="https://github.com/libevent/libevent/archive/refs/tags/release-2.1.12-stable.tar.gz"
export SOURCE_FILE="libevent-release-2.1.12-stable.tar.gz"
export MAKE_ARGS="--disable-dependency-tracking --disable-debug-mode"

source "../common/get_source.sh"
source "../common/make_build.sh"