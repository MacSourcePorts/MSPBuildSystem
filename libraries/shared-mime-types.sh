export MACOSX_DEPLOYMENT_TARGET="10.15"
export SOURCE_URL="https://gitlab.freedesktop.org/xdg/shared-mime-info/-/archive/2.4/shared-mime-info-2.4.tar.bz2"
export MESON_FLAGS=""
export XML_CATALOG_FILES="/usr/local/etc/xml/config"
export PATH=$PATH:~/Library/Python/3.9/bin/

source "../common/get_source.sh"

# Unlike most this one is just a bunch of flat files and one update program, we don't need to do Universal 2 there's no libraries

cd source/${SOURCE_FOLDER}
meson setup build
meson compile -C build --verbose
meson install -C build