export MACOSX_DEPLOYMENT_TARGET="10.7"
export PATH=$PATH:~/Library/Python/3.9/bin/

export SOURCE_URL="https://download.gnome.org/sources/glib/2.80/glib-2.80.3.tar.xz"

SOURCE_FILE=${SOURCE_URL##*/}

rm -rf source
mkdir source
cd source
curl -JLO ${SOURCE_URL}
tar -xzvf ${SOURCE_FILE}
SOURCE_FILE=${SOURCE_FILE%.*.*}
cd ${SOURCE_FILE}

# needed?
export PKG_CONFIG_PATH=/usr/local/bin/pkg-config

mkdir build-x86_64 build-arm64 build-universal2

export CFLAGS="-arch x86_64"
export LDFLAGS="-arch x86_64"
export CC="/usr/bin/clang"
export CXX="/usr/bin/clang++"

cd build-x86_64
meson setup -Dintrospection=disabled -Dbsymbolic_functions=false -Dbsymbolic_functions=false -Dtests=false --cross-file=../../../cross-x86_64.txt --prefix=/usr/local --libdir=lib --buildtype=release ../
ninja
cd ..

export CFLAGS="-arch arm64"
export LDFLAGS="-arch arm64"
export CC="/usr/bin/clang"
export CXX="/usr/bin/clang++"

# rm -rf subprojects/libffi

cd build-arm64
# meson setup --cross-file=../../../cross-arm64.txt --prefix=/usr/local --libdir=lib --buildtype=release ../
meson setup -Dintrospection=disabled -Dbsymbolic_functions=false -Dbsymbolic_functions=false -Dtests=false --cross-file=../../../cross-arm64.txt --prefix=/usr/local --libdir=lib --buildtype=release ../
ninja

# Apparently the "install" does more than just copy the dylibs
# so I'm going to let it do its thing in the build-arm64 folder
# and then just lipo the dylibs directly
sudo ninja install
cd ..

cp -r build-arm64/. build-universal2

cd build-arm64
for i in `find . -name "*.dylib" -type f`; do
    # echo "$i"
    LIB_NAME=${i##*/}
    LIB_PATH=${i##./}

    echo sudo lipo -create -output /usr/local/lib/${LIB_NAME} ../build-arm64/${LIB_PATH} ../build-x86_64/${LIB_PATH}
    sudo lipo -create -output /usr/local/lib/${LIB_NAME} ../build-arm64/${LIB_PATH} ../build-x86_64/${LIB_PATH}
done

cd ../build-universal2
