export SOURCE_URL="https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz"
export MAKE_ARGS="--disable-static --enable-shared --with-curses"

source "../common/get_source.sh"
source "../common/make_build.sh"