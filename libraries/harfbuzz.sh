source "./source_urls.sh"

export SOURCE_URL=${HARFBUZZ_URL}
export MESON_FLAGS="--default-library=both -Dcairo=enabled -Dcoretext=enabled -Dfreetype=enabled -Dglib=enabled -Dgobject=enabled -Dgraphite=enabled -Dicu=enabled -Dintrospection=disabled -Dtests=disabled"

source "../common/get_source.sh"
source "../common/meson_build.sh"