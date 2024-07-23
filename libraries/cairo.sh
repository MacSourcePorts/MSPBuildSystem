export SOURCE_URL="https://cairographics.org/releases/cairo-1.18.0.tar.xz"
export MESON_FLAGS="-Dfontconfig=enabled -Dfreetype=enabled -Dpng=enabled -Dglib=enabled -Dxcb=enabled -Dxlib=enabled -Dzlib=enabled -Dglib=enabled -Dquartz=enabled"

source "../common/get_source.sh"
source "../common/meson_build.sh"