source "./source_urls.sh"

export MACOSX_DEPLOYMENT_TARGET="10.7"
export SOURCE_URL=${RUBBERBAND_URL}
export PATH=$PATH:~/Library/Python/3.9/bin/

source "../common/get_source.sh"
# source "../common/meson_build.sh"

cd source/${SOURCE_FOLDER}

meson setup build --cross-file=../../cross-file.txt -Dresampler=libsamplerate  --prefix=/usr/local
sudo ninja -C build install