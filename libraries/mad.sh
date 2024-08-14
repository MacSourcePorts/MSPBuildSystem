export SOURCE_URL="https://downloads.sourceforge.net/project/mad/libmad/0.15.1b/libmad-0.15.1b.tar.gz"
export MAKE_ARGS="-disable-debugging --enable-fpm=64bit"
export CFLAGS=""
export LDFLAGS=""

source "../common/get_source.sh"

if [ -z "${SOURCE_FOLDER}" ]; then
    cd source/${SOURCE_FILE}
else
    cd source/${SOURCE_FOLDER}
fi

touch "NEWS"
touch "AUTHORS"
touch "ChangeLog"
autoreconf -fiv

cd ../..

source "../common/make_build.sh"