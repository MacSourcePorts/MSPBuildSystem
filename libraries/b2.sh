source "./source_urls.sh"

export SOURCE_URL=${B2_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-silent-rule"

source "../common/get_source.sh"

curl -JLO https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff
mv configure-big_sur.diff source
patch -d source/${SOURCE_FOLDER} < source/configure-big_sur.diff

source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libb2.1.dylib" /usr/local/lib/libb2.1.dylib