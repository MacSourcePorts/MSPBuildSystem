source "./source_urls.sh"

# minizip (KeeperFX) from zlib's contrib/minizip. Its CMake build wants a zlib
# CMake package, which our autotools-built zlib doesn't install, so it's
# compiled directly here, with a pkg-config file like the Linux distros ship.
export SOURCE_URL=${MINIZIP_URL}
export MACOSX_DEPLOYMENT_TARGET="10.14"

source "../common/get_source.sh"

MINIZIP_VERSION="1.3.2"

cd source/${SOURCE_FOLDER}/contrib/minizip
rm -rf build && mkdir -p build/include/minizip build/lib/pkgconfig

clang -arch arm64 -arch x86_64 -O2 -dynamiclib -DHAVE_UNISTD_H=1 \
	-I/usr/local/include -L/usr/local/lib -lz \
	-install_name @rpath/libminizip.1.dylib \
	-compatibility_version 1 -current_version ${MINIZIP_VERSION} \
	-o build/lib/libminizip.1.dylib ioapi.c unzip.c zip.c mztools.c
ln -sf libminizip.1.dylib build/lib/libminizip.dylib
cp ioapi.h unzip.h zip.h mztools.h crypt.h ints.h skipset.h build/include/minizip/

cat > build/lib/pkgconfig/minizip.pc <<PC
prefix=/usr/local
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: minizip
Description: Minizip zip file manipulation library
Version: ${MINIZIP_VERSION}
Requires: zlib
Libs: -L\${libdir} -lminizip
Cflags: -I\${includedir}/minizip
PC

sudo cp -v -R build/include/* /usr/local/include
sudo cp -v -R build/lib/* /usr/local/lib
