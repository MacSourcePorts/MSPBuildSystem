export SOURCE_URL="https://github.com/carlobaldassi/liblqr/archive/refs/tags/v0.4.3.tar.gz"
export SOURCE_FILE="liblqr-0.4.3.tar.gz"
export CONFIGURE_ARGS="--enable-install-man"

source "../common/get_source.sh"

curl -JLO https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-pre-0.4.2.418-big_sur.diff
mv configure-pre-0.4.2.418-big_sur.diff source
patch -d source/${SOURCE_FOLDER} < source/configure-pre-0.4.2.418-big_sur.diff

source "../common/make_build.sh"

# For some reason this one doesn't install right so let's do it manually

echo sudo mkdir /usr/local/include/lqr-1
sudo mkdir /usr/local/include/lqr-1
echo sudo cp lqr/*.h /usr/local/include/lqr-1
sudo cp lqr/*.h /usr/local/include/lqr-1
echo sudo cp -R lqr/.libs/*.dylib /usr/local/lib
sudo cp -R lqr/.libs/*.dylib /usr/local/lib
echo sudo cp -R lqr-1.pc /usr/local/lib/pkgconfig
sudo cp -R lqr-1.pc /usr/local/lib/pkgconfig