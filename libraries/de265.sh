export SOURCE_URL="https://github.com/strukturag/libde265/releases/download/v1.0.15/libde265-1.0.15.tar.gz"
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-silent-rules --disable-sherlock265 --disable-dec265"

source "../common/get_source.sh"

curl -JLO https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff
mv configure-big_sur.diff source
patch -d source/${SOURCE_FOLDER} < source/configure-big_sur.diff

source "../common/make_build.sh"