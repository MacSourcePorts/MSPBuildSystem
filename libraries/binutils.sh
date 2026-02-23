source "./source_urls.sh"

export SOURCE_URL=${BINUTILS_URL}
export RANLIB=/usr/bin/ranlib
export AR=/usr/bin/ar

source "../common/get_source.sh"

# Because binutils has an issue with being made for Universal 2 
# and because we use it as utilities and not linked into executables
# I'm doing just the one architecture here instead of Universal 2.

cd source/${SOURCE_FOLDER}
mkdir build
cd build
../configure --disable-debug --disable-dependency-tracking --enable-deterministic-archives --disable-werror --enable-interwork --enable-multilib --enable-64-bit-bfd --enable-gold --enable-plugins --enable-targets=all --with-system-zlib --with-zstd --disable-nl 
#--enable-install-libiberty
make 
sudo make install