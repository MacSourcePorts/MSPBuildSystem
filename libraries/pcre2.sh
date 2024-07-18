export SOURCE_URL="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.44/pcre2-10.44.tar.bz2"
export MAKE_ARGS="--disable-static --enable-shared --disable-dependency-tracking --enable-pcre2-16 --enable-pcre2-32 --enable-pcre2grep-libz --enable-pcre2grep-libbz2 --enable-jit --enable-pcre2test-libedit"

source "../common/get_source.sh"
source "../common/make_build.sh"