export SOURCE_URL="https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.xz"

export AR=/usr/bin/ar
export RANLIB=/usr/bin/ranlib

source "../common/get_source.sh"

cd source/${SOURCE_FOLDER}

# Build libiberty for x86_64
mkdir build-x86_64
cd build-x86_64
CC="clang -arch x86_64" \
CFLAGS="-arch x86_64 -mmacosx-version-min=10.13" \
../libiberty/configure --disable-nls --enable-shared --enable-install-libiberty --host=x86_64-apple-darwin --prefix=/tmp/libiberty-x86_64
make
cd ..

# Build libiberty for arm64
mkdir build-arm64
cd build-arm64
CC="clang -arch arm64" \
CFLAGS="-arch arm64 -mmacosx-version-min=11.0" \
../libiberty/configure --disable-nls --enable-shared --enable-install-libiberty --host=arm-apple-darwin --prefix=/tmp/libiberty-arm64
make
cd ..

# Create Universal libiberty.a
sudo lipo -create build-arm64/libiberty.a build-x86_64/libiberty.a -output /usr/local/lib/libiberty.a