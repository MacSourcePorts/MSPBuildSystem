export MACOSX_DEPLOYMENT_TARGET="10.7"
export NCPU=`sysctl -n hw.ncpu`

rm -rf build
mkdir build
cd build

mkdir build-x86_64
cd build-x86_64
echo cmake ../../source/${SOURCE_FOLDER} -DCMAKE_OSX_ARCHITECTURES=x86_64 -DCMAKE_INSTALL_PREFIX=/usr/local ${CMAKE_ARGS} ${CCONFIGURE_X86_64_ARGS}
cmake ../../source/${SOURCE_FOLDER} -DCMAKE_OSX_ARCHITECTURES=x86_64 -DCMAKE_INSTALL_PREFIX=/usr/local ${CMAKE_ARGS} ${CCONFIGURE_X86_64_ARGS}
cmake --build . --parallel $NCPU

cd ..
mkdir build-arm64
cd build-arm64
echo cmake ../../source/${SOURCE_FOLDER} -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_INSTALL_PREFIX=/usr/local ${CMAKE_ARGS} ${CCONFIGURE_ARM64_ARGS}
cmake ../../source/${SOURCE_FOLDER} -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_INSTALL_PREFIX=/usr/local ${CMAKE_ARGS} ${CCONFIGURE_ARM64_ARGS}
cmake --build . --parallel $NCPU

# Building this a THIRD time just to have the things in the right place
# is the dumbest thing in the world but for now it works. 
# TODO: I can't lipo a dylib of itself can I?
cd ..
mkdir build-universal2
cd build-universal2
cmake ../../source/${SOURCE_FOLDER} -DCMAKE_INSTALL_PREFIX=/usr/local ${CMAKE_ARGS}
cmake --build . --parallel $NCPU
for lib in ../build-arm64/*.dylib; do
    libname=$(basename $lib)
    echo "lipo -create -output $libname ../build-arm64/$libname ../build-x86_64/$libname"
    lipo -create -output $libname ../build-arm64/$libname ../build-x86_64/$libname
done
sudo cmake --install .