export SOURCE_URL="https://github.com/harfbuzz/harfbuzz/archive/refs/tags/9.0.0.tar.gz"
export SOURCE_FILE="harfbuzz-9.0.0.tar.gz"
export MESON_FLAGS="--default-library=both -Dcairo=enabled -Dcoretext=enabled -Dfreetype=enabled -Dglib=enabled -Dgobject=enabled -Dgraphite=enabled -Dicu=enabled -Dintrospection=disabled -Dtests=disabled"

source "../common/get_source.sh"
source "../common/meson_build.sh"