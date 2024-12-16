export SOURCE_URL="https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz"
export CONFIGURE_ARGS="--disable-static --enable-shared --with-curses"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libreadline.8.2.dylib" /usr/local/lib/libreadline.8.2.dylib
sudo install_name_tool -id "@rpath/libhistory.8.2.dylib" /usr/local/lib/libhistory.8.2.dylib
