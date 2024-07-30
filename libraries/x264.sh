export MAKE_ARGS="--disable-lsmash --disable-swscale --disable-ffms --enable-shared --enable-static --enable-strip"
export SOURCE_FOLDER="x264"

rm -rf source
mkdir source
cd source
git clone https://code.videolan.org/videolan/x264.git
cd x264
git checkout 31e19f92f00c7003fa115047ce50978bc98c3a0d
cd ../..

source "../common/make_build_lipo.sh"