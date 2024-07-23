export PATH="/usr/local/bin:$PATH"
export SOURCE_URL="https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz"
export MAKE_ARGS="--disable-dependency-tracking --enable-relocatable M4=m4"

source "../common/get_source.sh"
source "../common/make_build.sh"