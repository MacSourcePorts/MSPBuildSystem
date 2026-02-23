source "./source_urls.sh"

export SOURCE_URL=${BLURAY_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-silent-rules --disable-bdjava-jar"

source "../common/get_source.sh"
source "../common/meson_build.sh"

sudo install_name_tool -id "@rpath/libbluray.2.dylib" /usr/local/lib/libbluray.2.dylib