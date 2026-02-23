source "./source_urls.sh"

export SOURCE_URL="https://gitlab.freedesktop.org/fontconfig/fontconfig/-/archive/2.17.1/fontconfig-2.17.1.tar.gz"
export CONFIGURE_ARGS="--default-library=both -Ddoc=disabled -Dtests=disabled -Dtools=enabled -Dcache-build=disabled -Dadditional-fonts-dirs==/System/Library/Fonts,/Library/Fonts,~/Library/Fonts"

source "../common/get_source.sh"
source "../common/meson_build.sh"