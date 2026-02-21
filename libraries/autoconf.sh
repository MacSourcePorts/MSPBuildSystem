export SOURCE_URL="http://mirrors.ibiblio.org/gnu/autoconf/autoconf-2.72.tar.xz"

source "../common/get_source.sh"

cd source/${SOURCE_FOLDER}

./configure
make
sudo make install