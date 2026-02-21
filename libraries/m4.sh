export SOURCE_URL="https://ftp.gnu.org/gnu/m4/m4-1.4.21.tar.xz"

source "../common/get_source.sh"

cd source/${SOURCE_FOLDER}

./configure
make
sudo make install
sudo install_name_tool -add_rpath /usr/local/lib/. /usr/local/bin/m4