source "./source_urls.sh"

# libnatpmp (KeeperFX) -- its Makefile builds one architecture at a time, so
# build both and lipo them together, as with miniupnpc
export MACOSX_DEPLOYMENT_TARGET="10.14"
export SOURCE_URL=${NATPMP_URL}

source "../common/get_source.sh"

cd source/${SOURCE_FOLDER}

rm -rf build-arm64 build-x86_64 build-universal2

for ARCH in arm64 x86_64; do
	make clean
	make CC="clang -arch ${ARCH}" INSTALLPREFIX=$PWD/build-${ARCH} install
done

cp -a build-arm64/. build-universal2
# natpmp.h includes natpmp_declspec.h, which "make install" leaves out
cp natpmp_declspec.h build-universal2/include/

cd build-arm64
for i in `find . -name "*.dylib" -type f`; do
	LIB_NAME=${i##*/}
	LIB_PATH=${i##./}
	lipo -create -output ../build-universal2/${LIB_PATH} ../build-arm64/${LIB_PATH} ../build-x86_64/${LIB_PATH}
	install_name_tool -id @rpath/${LIB_NAME} ../build-universal2/${LIB_PATH}
done
for i in `find . -name "*.a" -type f`; do
	LIB_PATH=${i##./}
	lipo -create -output ../build-universal2/${LIB_PATH} ../build-arm64/${LIB_PATH} ../build-x86_64/${LIB_PATH}
done

cd ../build-universal2

sudo cp -v -R include/* /usr/local/include
sudo cp -v -R lib/* /usr/local/lib
