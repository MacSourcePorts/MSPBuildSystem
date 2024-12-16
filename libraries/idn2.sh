# NOTE: Has an issue when installing, but libidn2 dylibs are stll installed. 
# Unsure if this is going to be an issue but moving on for now.

export SOURCE_URL="https://ftp.gnu.org/gnu/libidn/libidn2-2.3.7.tar.gz"
export CONFIGURE_ARGS="--disable-silent-rules"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libidn2.0.dylib" /usr/local/lib/libidn2.0.dylib