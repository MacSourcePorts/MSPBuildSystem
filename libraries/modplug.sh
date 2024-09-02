export SOURCE_URL="https://downloads.sourceforge.net/project/modplug-xmms/libmodplug/0.8.9.0/libmodplug-0.8.9.0.tar.gz"
export CONFIGURE_ARGS="--disable-debug --disable-dependency-tracking --disable-silent-rules --disable-static"

source "../common/get_source.sh"
curl -JLO https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff
mv configure-big_sur.diff source
patch -d source/${SOURCE_FOLDER} < source/configure-big_sur.diff

source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libmodplug.1.dylib" /usr/local/lib/libmodplug.1.dylib