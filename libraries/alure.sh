# This is an ancient dependency of Daikatana
# Just to make things easy I'm going to just use the .tar.gz file that comes with Daikatana's souce
# but install it Universal 2 to the usual spot

rm -rf source
mkdir source
cd source
cp ../../../daikatana-1.3/vendor/alure-1.x.tar.gz .
tar -xzvf alure-1.x.tar.gz
cp ../../../daikatana-1.3/vendor/cmake-alure CMakeLists.txt
export SOURCE_FOLDER=alure-1.x

cd ..

export CFLAGS="-mmacosx-version-min=10.9 -arch arm64 -arch x86_64"
export CXXFLAGS="-mmacosx-version-min=10.9 -stdlib=libc++ -arch arm64 -arch x86_64"
export LDFLAGS="-mmacosx-version-min=10.9 -stdlib=libc++ -std=c++11 -arch arm64 -arch x86_64"
export CMAKE_C_FLAGS=$CFLAGS
export CMAKE_CXX_FLAGS=$CXXFLAGS
export CMAKEMODULE_LINKER_FLAGS=$LDFLAGS
export CMAKEMODULE_SHARED_LINKER_FLAGS=$LDFLAGS

export CMAKE_C_FLAGS="-mmacosx-version-min=10.9 -I/usr/local/opt/openal-soft/include -arch arm64 -arch x86_64"
export CMAKE_CXX_FLAGS="-mmacosx-version-min=10.9 -stdlib=libc++ -std=c++11 -I/usr/local/opt/openal-soft/include -arch arm64 -arch x86_64"

rm -rf build
mkdir build || true
cd build

# cmake -DVORBIS=OFF -DBUILD_SHARED=ON -DBUILD_STATIC=ON -DCMAKE_SYSTEM_INCLUDE_PATH=${VENDOR_BASEPATH} -DOPENALDIR=${VENDOR_BASEPATH} -DCMAKE_INSTALL_PREFIX=${VENDOR_BASEPATH}  -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" ..
export NCPU=`sysctl -n hw.ncpu`
cmake -DFLUIDSYNTH=OFF -DVORBIS=OFF -DBUILD_SHARED=ON -DBUILD_STATIC=ON -DOPENAL_LIBRARY=/usr/local/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/usr/local/include/AL -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" ../source/${SOURCE_FOLDER}
cmake --build . --parallel $NCPU
sudo cmake --install .

sudo install_name_tool -id "@rpath/libalure.1.dylib" /usr/local/lib/libalure.1.dylib