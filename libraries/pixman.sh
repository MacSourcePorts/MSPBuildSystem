# NOTE: Has an issue when building, but libpixman dylibs are stll installed. 
# Unsure if this is going to be an issue but moving on for now.
# Also it's supposed to use meson/ninja but that fails outright.

export SOURCE_URL="https://cairographics.org/releases/pixman-0.42.2.tar.gz"
export CONFIGURE_ARGS="--disable-silent-rules --disable-gtk"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libpixman-1.0.42.2.dylib" /usr/local/lib/libpixman-1.0.42.2.dylib