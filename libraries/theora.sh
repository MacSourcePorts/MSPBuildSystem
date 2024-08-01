export SOURCE_URL="https://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.bz2"
export MAKE_ARGS="--disable-dependency-tracking --disable-oggtest --disable-vorbistest --disable-examples"

source "../common/get_source.sh"

curl -JLO https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-pre-0.4.2.418-big_sur.diff
mv configure-pre-0.4.2.418-big_sur.diff source
patch -d source/${SOURCE_FOLDER} < source/configure-pre-0.4.2.418-big_sur.diff

source "../common/make_build.sh"