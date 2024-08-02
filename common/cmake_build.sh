if [ -z "${MACOSX_DEPLOYMENT_TARGET}" ]; then
    export MACOSX_DEPLOYMENT_TARGET="10.7"
fi
export NCPU=`sysctl -n hw.ncpu`

rm -rf build
mkdir build
cd build
cmake ../source/${SOURCE_FOLDER} "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" ${CMAKE_ARGS}
cmake --build . --parallel $NCPU
sudo cmake --install .