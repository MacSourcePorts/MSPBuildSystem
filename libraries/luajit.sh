source "./source_urls.sh"

# LuaJIT 2.1 (KeeperFX). Built once per architecture (it generates
# architecture-specific code at build time) and lipo'd together. Headers go to
# /usr/local/include/luajit-2.1, apart from Lua 5.5's.
export MACOSX_DEPLOYMENT_TARGET="10.14"
export SOURCE_URL=${LUAJIT_URL}
export NCPU=`sysctl -n hw.ncpu`

source "../common/get_source.sh"

cd source/${SOURCE_FOLDER}

rm -rf build-arm64 build-x86_64 build-universal2

# Apple's ar and strip: GNU binutils' in /usr/local/bin (if present) don't
# handle Mach-O properly, and may not even run. (-x is what the Makefile adds
# for macOS, which setting TARGET_STRIP here overrides; without it strip would
# remove the library's exported symbols too.)
for ARCH in arm64 x86_64; do
	make clean
	make -j$NCPU PREFIX=/usr/local CC="clang" TARGET_FLAGS="-arch ${ARCH}" \
		TARGET_AR="/usr/bin/ar rcus" TARGET_STRIP="/usr/bin/strip -x" || exit 1
	make install PREFIX=/usr/local DESTDIR=$PWD/build-${ARCH} || exit 1
done

cp -a build-arm64/usr/local/. build-universal2

cd build-arm64/usr/local
for i in `find lib -name "*.dylib" -type f` `find lib -name "*.a" -type f` bin/luajit-*; do
	lipo -create -output ../../../build-universal2/$i $i ../../../build-x86_64/usr/local/$i
done
cd ../../../build-universal2
for i in `find lib -name "*.dylib" -type f`; do
	install_name_tool -id @rpath/libluajit-5.1.2.dylib $i
done

sudo cp -v -R include/* /usr/local/include
sudo cp -v -R lib/* /usr/local/lib
