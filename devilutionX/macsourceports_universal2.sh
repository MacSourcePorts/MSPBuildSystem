# game/app specific values
export APP_VERSION="1.5.0"
export PRODUCT_NAME="devilutionX"
export PROJECT_NAME="devilutionX"
export PORT_NAME="DevilutionX"
export ICONSFILENAME="devilutionX"
export EXECUTABLE_NAME="devilutionX"
export PKGINFO="APPLEDVLX"
export GIT_TAG="1.5.0"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

# Temporary hack until either SDL or Devilution fix it
git checkout .

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

# check out the latest release tag
echo git checkout tags/${GIT_TAG}
git checkout tags/${GIT_TAG}

# Temporary hack until either SDL or Devilution fix it
cp -a "../MSPBuildSystem/devilutionx/CMakeLists.txt" .
cp -a "../MSPBuildSystem/devilutionx/Dependencies.cmake" ./CMake

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
sodium_INCLUDE_DIR=/usr/local/include
sodium_LIBRARY_DEBUG=/usr/local/lib/libsodium.dylib
sodium_LIBRARY_RELEASE=/usr/local/lib/libsodium.dylib
/usr/local/bin/cmake -G "Unix Makefiles" -DBUILD_TESTING=OFF -DVERSION_NUM=${APP_VERSION} -DCMAKE_C_FLAGS_RELEASE="-arch x86_64" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2_DIR=/usr/local/opt/sdl2/lib/cmake/SDL2 -DSDL2_INCLUDE_DIRS=/usr/local/opt/sdl2/include/SDL2 -DSDL2_LIBRARIES=/usr/local/opt/sdl2/lib -DPKG_CONFIG_EXECUTABLE=/usr/local/bin/pkg-config -DDEVILUTIONX_SYSTEM_LIBFMT=OFF .. -Wno-dev

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -G "Unix Makefiles" -DBUILD_TESTING=OFF -DVERSION_NUM=${APP_VERSION} -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 .. -Wno-dev

# perform builds with make
cd ..
cd ${X86_64_BUILD_FOLDER}
make -j$NCPU

cd ..
cd ${ARM64_BUILD_FOLDER}
make -j$NCPU

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"