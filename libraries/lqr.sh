export SOURCE_URL="https://github.com/carlobaldassi/liblqr/archive/refs/tags/v0.4.3.tar.gz"
export SOURCE_FILE="liblqr-0.4.3.tar.gz"
export CONFIGURE_ARGS="--enable-install-man --prefix=/usr/local"

source "../common/get_source.sh"

curl -JLO https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-pre-0.4.2.418-big_sur.diff
mv configure-pre-0.4.2.418-big_sur.diff source
patch -d source/${SOURCE_FOLDER} < source/configure-pre-0.4.2.418-big_sur.diff

source "../common/make_build.sh"