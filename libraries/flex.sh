export SOURCE_URL="https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz"
export CONFIGURE_ARGS="--disable-silent-rules --disable-shared"

source "../common/get_source.sh"

curl -JLO https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff
mv configure-big_sur.diff source
patch -d source/${SOURCE_FOLDER} < source/configure-big_sur.diff

sudo install_name_tool -id "/usr/local/lib/libintl.8.dylib" /usr/local/lib/libintl.8.dylib

source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libintl.8.dylib" /usr/local/lib/libintl.8.dylib