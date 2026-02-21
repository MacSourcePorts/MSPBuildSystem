export SOURCE_URL="https://ftp.gnu.org/gnu/automake/automake-1.18.1.tar.xz"

source "../common/get_source.sh"

cd source/${SOURCE_FOLDER}

./configure
make
sudo make install