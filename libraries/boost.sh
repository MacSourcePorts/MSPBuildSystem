export SOURCE_URL="https://github.com/boostorg/boost/releases/download/boost-1.86.0/boost-1.86.0-b2-nodocs.tar.xz"
export SOURCE_DIR="boost-1.86.0"
INSTALL_PREFIX="universal2"

export MACOSX_DEPLOYMENT_TARGET="10.8"
export NCPU=`sysctl -n hw.ncpu`

if [ -z "${SOURCE_FILE}" ]; then
    SOURCE_FILE=${SOURCE_URL##*/}
fi

rm -rf source
mkdir source
cd source
curl -JLO ${SOURCE_URL}
tar -xzvf ${SOURCE_FILE}
cd ${SOURCE_DIR}

# *** modified from brew.sh site
# ./bootstrap.sh --without-libraries=python,mpi
# ./b2 headers
# ./b2 -d2 -j$NCPU --layout=tagged-1.66 install threading=multi,single link=shared,static cxxflags=-stdlib=libc++ linkflags=-stdlib=libc++

# ***** from a SO link
# https://stackoverflow.com/a/69924892
rm -rf arm64 x86_64 universal stage bin.v2
rm -f b2 project-config*

./bootstrap.sh cxxflags="-arch x86_64 -arch arm64" cflags="-arch x86_64 -arch arm64" linkflags="-arch x86_64 -arch arm64" --prefix=$INSTALL_PREFIX
./b2 install --with=all --include
./b2 toolset=clang-darwin target-os=darwin architecture=arm abi=aapcs cxxflags="-arch arm64" cflags="-arch arm64" linkflags="-arch arm64" --stagedir=stage/arm64 -a
./b2 toolset=clang-darwin target-os=darwin architecture=x86 cxxflags="-arch x86_64" cflags="-arch x86_64" linkflags="-arch x86_64" abi=sysv binary-format=mach-o  --stagedir=stage/x86_64 -a
for lib in stage/x86_64/lib/*.dylib; do
    libname=$(basename $lib)
    echo "lipo -create -output $INSTALL_PREFIX/lib/$libname stage/x86_64/lib/$libname stage/arm64/lib/$libname"
    lipo -create -output $INSTALL_PREFIX/lib/$libname stage/x86_64/lib/$libname stage/arm64/lib/$libname
done

sudo cp -v -R universal2/* /usr/local/