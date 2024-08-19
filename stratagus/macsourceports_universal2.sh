# game/app specific values
export APP_VERSION="0.69"
#starting with Wargus (Warcraft 2)
export PRODUCT_NAME="Wargus"
export PROJECT_NAME="stratagus"
export PORT_NAME="Wargus"
export ICONSFILENAME="wargus"
export EXECUTABLE_NAME="wargus"
export PKGINFO="APPLWG2"
export GIT_DEFAULT_BRANCH="master"
export GIT_TAG="v3.3.2"

#constants
source ../common/constants.sh
source ../common/signing_values.local

# go to main stratagus directory
cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

# reset to the main branch
# echo git checkout ${GIT_DEFAULT_BRANCH}
# git checkout ${GIT_DEFAULT_BRANCH}

# # fetch the latest 
echo git pull
git pull

# first, build stratagus
cd stratagus 

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake -DBUILD_VENDORED_LUA=ON \
-DCMAKE_OSX_ARCHITECTURES=x86_64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
..
make -j $NCPU
cd ..

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -DBUILD_VENDORED_LUA=ON \
# -DCMAKE_OSX_ARCHITECTURES=arm64 \
# -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
# -DCMAKE_PREFIX_PATH=/opt/Homebrew \
# -DCMAKE_INSTALL_PREFIX=/opt/Homebrew \
..
make -j $NCPU
cd ../.. 

# ???
# export STRATAGUS_INCLUDE_DIR=${PWD}/stratagus/gameheaders
# export STRATAGUS=${PWD}/stratagus/build/stratagus

#next, build wargus (Warcraft 2)

cd wargus
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake -DSTRATAGUS_INCLUDE_DIR=${PWD}/../../stratagus/gameheaders \
-DSTRATAGUS=${PWD}/../../stratagus/${X86_64_BUILD_FOLDER}/stratagus \
-DCMAKE_OSX_ARCHITECTURES=x86_64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
..
make -j $NCPU
cd ../mac
export STRATAGUS_INCLUDE_DIR=${PWD}/../../stratagus/gameheaders
export STRATAGUS=${PWD}/../../stratagus/${X86_64_BUILD_FOLDER}/stratagus
./bundle.sh
cp ../${X86_64_BUILD_FOLDER}/wartool Wargus.app/Contents/MacOS/
cp ../${X86_64_BUILD_FOLDER}/wargus Wargus.app/Contents/MacOS/
cp -a Wargus.app ../../${X86_64_BUILD_FOLDER}
cd ..

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -DSTRATAGUS_INCLUDE_DIR=${PWD}/../../stratagus/gameheaders \
-DSTRATAGUS=${PWD}/../../stratagus/${ARM64_BUILD_FOLDER}/stratagus \
# -DCMAKE_OSX_ARCHITECTURES=arm64 \
# -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
# -DCMAKE_PREFIX_PATH=/opt/Homebrew \
# -DCMAKE_INSTALL_PREFIX=/opt/Homebrew \
..
make -j $NCPU
cd ../mac
export STRATAGUS_INCLUDE_DIR=${PWD}/../../stratagus/gameheaders
export STRATAGUS=${PWD}/../../stratagus/${ARM64_BUILD_FOLDER}/stratagus
./bundle.sh
cp ../${ARM64_BUILD_FOLDER}/wartool Wargus.app/Contents/MacOS/
cp ../${ARM64_BUILD_FOLDER}/wargus Wargus.app/Contents/MacOS/
cp -a Wargus.app ../../${ARM64_BUILD_FOLDER}
cd ..

# install_name_tool -change @rpath/libTempest.dylib @executable_path/libTempest.dylib "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

# create the app bundle
cd ..
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

rm -rf ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}
rm -rf ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}
# lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/stratagus ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/stratagus -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/stratagus" -create
# codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/stratagus
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/wartool ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/wartool -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/wartool" -create
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/wartool

mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/campaigns
cp -a ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/campaigns/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/campaigns
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/contrib
cp -a ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/contrib/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/contrib
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/maps
cp -a ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/maps/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/maps
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/scripts
cp -a ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/scripts/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/scripts
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/shaders
cp -a ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/shaders/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/shaders

rm ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist
cp wargus/mac/Info.plist ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}

# sign and notarize
# "../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# # create dmg
# "../MSPBuildSystem/common/package_dmg.sh"