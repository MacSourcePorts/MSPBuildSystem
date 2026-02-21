export SOURCE_URL="https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz"

source "../common/get_source.sh"

cd source/${SOURCE_FOLDER}

./configure --disable-dependency-tracking --program-prefix=g
sudo install_name_tool -id "/usr/local/lib/libintl.8.dylib" /usr/local/lib/libintl.8.dylib
make
sudo make install
sudo install_name_tool -id "@rpath/libintl.8.dylib" /usr/local/lib/libintl.8.dylib