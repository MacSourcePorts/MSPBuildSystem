# game/app specific values
export APP_VERSION="0.75"
export PRODUCT_NAME="OpenGothic"
export PROJECT_NAME="OpenGothic"
export PORT_NAME="OpenGothic"
export ICONSFILENAME="opengothic"
export EXECUTABLE_NAME="Gothic2Notr"
export PKGINFO="APPLOGw"
export GIT_DEFAULT_BRANCH="master"
export GIT_TAG="v0.75"

#constants
source ../common/constants.sh
source ../common/signing_values.local

cd ../../${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# # fetch the latest 
echo git pull
git pull

# check out the latest release tag
# echo git checkout tags/${GIT_TAG}
# git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake, perform builds with make
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd ${X86_64_BUILD_FOLDER}
cmake -H. -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
-DCMAKE_OSX_ARCHITECTURES=x86_64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
..
cmake --build . --target Gothic2Notr -j $NCPU
cp opengothic/${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
cp opengothic/libTempest.dylib ${EXECUTABLE_FOLDER_PATH}
install_name_tool -change @rpath/libTempest.dylib @executable_path/libTempest.dylib "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd ${ARM64_BUILD_FOLDER}
cmake -H. -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
-DCMAKE_OSX_ARCHITECTURES=arm64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/opt/Homebrew \
-DCMAKE_INSTALL_PREFIX=/opt/Homebrew \
..
cmake --build . --target Gothic2Notr -j $NCPU
cp opengothic/${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
cp opengothic/libTempest.dylib ${EXECUTABLE_FOLDER_PATH}
install_name_tool -change @rpath/libTempest.dylib @executable_path/libTempest.dylib "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

rm -rf ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}
rm -rf ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libTempest.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libTempest.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libTempest.dylib" -create
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libTempest.dylib

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"