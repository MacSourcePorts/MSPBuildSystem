# NOTE: Has an issue when building, but libunistring dylibs are stll installed. 
# Unsure if this is going to be an issue but moving on for now.

export SOURCE_URL="https://ftp.gnu.org/gnu/libunistring/libunistring-1.2.tar.gz"
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-silent-rules"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libunistring.5.dylib" /usr/local/lib/libunistring.5.dylib
