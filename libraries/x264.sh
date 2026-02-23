source "./source_urls.sh"

export CONFIGURE_ARGS="--disable-lsmash --disable-swscale --disable-ffms --enable-shared --enable-static --enable-strip"
export SOURCE_FOLDER="x264"

rm -rf source
mkdir source
cd source
git clone ${X264_URL}
cd x264
git checkout 31e19f92f00c7003fa115047ce50978bc98c3a0d
cd ../..

source "../common/make_build_lipo.sh"