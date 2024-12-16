# NOTE: Has an issue when installing, but libtasn dylibs are stll installed. 
# Unsure if this is going to be an issue but moving on for now.

export SOURCE_URL="https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.19.0.tar.gz"
export CONFIGURE_ARGS="--disable-silent-rules --disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libtasn1.6.dylib" /usr/local/lib/libtasn1.6.dylib