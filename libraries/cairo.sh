source "./source_urls.sh"

export SOURCE_URL=${CAIRO_URL}
export MESON_FLAGS="-Dfontconfig=enabled -Dfreetype=enabled -Dpng=enabled -Dglib=enabled -Dxcb=enabled -Dxlib=enabled -Dzlib=enabled -Dglib=enabled -Dquartz=enabled"

source "../common/get_source.sh"
source "../common/meson_build.sh"