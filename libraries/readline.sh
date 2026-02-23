source "./source_urls.sh"

export SOURCE_URL=${READLINE_URL}
export CONFIGURE_ARGS="--disable-static --enable-shared --with-curses"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libreadline.8.2.dylib" /usr/local/lib/libreadline.8.2.dylib
sudo install_name_tool -id "@rpath/libhistory.8.2.dylib" /usr/local/lib/libhistory.8.2.dylib