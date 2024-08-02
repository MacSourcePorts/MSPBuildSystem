export SOURCE_URL="https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.bz2"

source "../common/get_source.sh"

# Because binutils has an issue with being made for Universal 2 
# and because we use it as utilities and not linked into executables
# I'm doing just the one architecture here instead of Universal 2.

sudo install_name_tool -id "/usr/local/lib/libzstd.1.5.6.dylib" /usr/local/lib/libzstd.1.5.6.dylib

cd source/${SOURCE_FOLDER}
mkdir build
cd build
../configure --disable-debug --disable-dependency-tracking --enable-deterministic-archives --disable-werror --enable-interwork --enable-multilib --enable-64-bit-bfd --enable-gold --enable-plugins --enable-targets=all --with-system-zlib --with-zstd --disable-nl
make 
sudo make install

sudo install_name_tool -id "@rpath/libzstd.1.dylib" /usr/local/lib/libzstd.1.5.6.dylib
