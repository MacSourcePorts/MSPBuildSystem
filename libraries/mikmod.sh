export SOURCE_URL="https://downloads.sourceforge.net/project/mikmod/libmikmod/3.3.11.1/libmikmod-3.3.11.1.tar.gz"

export CONFIGURE_ARGS="--disable-alsa --disable-sam9407 --disable-ultra"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libmikmod.3.dylib" /usr/local/lib/libmikmod.3.dylib