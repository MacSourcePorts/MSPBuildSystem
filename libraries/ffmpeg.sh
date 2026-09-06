source "./source_urls.sh"

export SOURCE_URL=${FFMPEG_URL}

export CONFIGURE_ARGS="--enable-cross-compile --target-os=darwin --disable-libzimg --disable-librav1e --disable-libtesseract --enable-shared --enable-pthreads --enable-version3 --enable-ffplay --enable-gnutls --enable-gpl --enable-libaom --enable-libaribb24 --enable-libbluray --enable-libdav1d --enable-libharfbuzz --enable-libjxl --enable-libmp3lame --enable-libopus --enable-librist --enable-librubberband --enable-libsnappy --enable-libsrt --enable-libssh --enable-libsvtav1 --enable-libtheora --enable-libvidstab --enable-libvmaf --enable-libvorbis --enable-libvpx --enable-libwebp --enable-libx264 --enable-libx265 --enable-libxml2 --enable-libxvid --enable-lzma --enable-libfontconfig --enable-libfreetype --enable-frei0r --enable-libass --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libopenjpeg --enable-libspeex --enable-libsoxr --enable-libzmq --disable-libjack --disable-indev=jack --enable-videotoolbox --enable-audiotoolbox"
export CONFIGURE_ARM64_ARGS="--arch=arm64"
export CONFIGURE_X86_64_ARGS="--arch=x86_64"
export MACOSX_DEPLOYMENT_TARGET="10.8"

source "../common/get_source.sh"

# curl -JLO https://gitlab.archlinux.org/archlinux/packaging/packages/ffmpeg/-/raw/5670ccd86d3b816f49ebc18cab878125eca2f81f/add-av_stream_get_first_dts-for-chromium.patch
# mv add-av_stream_get_first_dts-for-chromium.patch source
# echo patch -d source/${SOURCE_FOLDER} < source/add-av_stream_get_first_dts-for-chromium.patch
# patch -d source/${SOURCE_FOLDER} < source/add-av_stream_get_first_dts-for-chromium.patch

source "../common/make_build_lipo2.sh"

cd ../../..
sudo lipo -create -output /usr/local/lib/libpostproc.58.1.100.dylib source/${SOURCE_FOLDER}/build-arm64/libpostproc/libpostproc.58.dylib source/${SOURCE_FOLDER}/build-x86_64/libpostproc/libpostproc.58.dylib
sudo lipo -create -output /usr/local/lib/libavfilter.10.1.100.dylib source/${SOURCE_FOLDER}/build-arm64/libavfilter/libavfilter.10.dylib source/${SOURCE_FOLDER}/build-x86_64/libavfilter/libavfilter.10.dylib
sudo lipo -create -output /usr/local/lib/libavdevice.61.1.100.dylib source/${SOURCE_FOLDER}/build-arm64/libavdevice/libavdevice.61.dylib source/${SOURCE_FOLDER}/build-x86_64/libavdevice/libavdevice.61.dylib
sudo lipo -create -output /usr/local/lib/libavformat.61.1.100.dylib source/${SOURCE_FOLDER}/build-arm64/libavformat/libavformat.61.dylib source/${SOURCE_FOLDER}/build-x86_64/libavformat/libavformat.61.dylib
sudo lipo -create -output /usr/local/lib/libavcodec.61.3.100.dylib source/${SOURCE_FOLDER}/build-arm64/libavcodec/libavcodec.61.dylib source/${SOURCE_FOLDER}/build-x86_64/libavcodec/libavcodec.61.dylib
sudo lipo -create -output /usr/local/lib/libavutil.59.8.100.dylib source/${SOURCE_FOLDER}/build-arm64/libavutil/libavutil.59.dylib source/${SOURCE_FOLDER}/build-x86_64/libavutil/libavutil.59.dylib
sudo lipo -create -output /usr/local/lib/libswscale.8.1.100.dylib source/${SOURCE_FOLDER}/build-arm64/libswscale/libswscale.8.dylib source/${SOURCE_FOLDER}/build-x86_64/libswscale/libswscale.8.dylib
sudo lipo -create -output /usr/local/lib/libswresample.5.1.100.dylib source/${SOURCE_FOLDER}/build-arm64/libswresample/libswresample.5.dylib source/${SOURCE_FOLDER}/build-x86_64/libswresample/libswresample.5.dylib