# https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.15.0.tar.xz
export SOURCE_URL="https://downloads.sourceforge.net/project/freetype/freetype2/2.13.2/freetype-2.13.2.tar.xz"
export MAKE_ARGS="--disable-dependency-tracking --disable-silent-rules --disable-docs --enable-static--with-add-fonts=/System/Library/Fonts,/Library/Fonts,~/Library/Fonts"

source "../common/get_source.sh"
source "../common/make_build.sh"