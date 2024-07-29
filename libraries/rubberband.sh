export MACOSX_DEPLOYMENT_TARGET="10.7"
export SOURCE_URL="https://breakfastquay.com/files/releases/rubberband-3.3.0.tar.bz2"
export PATH=$PATH:~/Library/Python/3.9/bin/

source "../common/get_source.sh"
# source "../common/meson_build.sh"

cd source/rubberband-3.3.0

meson setup build --cross-file=../../cross-file.txt -Dresampler=libsamplerate  --prefix=/usr/local
ninja -C build install