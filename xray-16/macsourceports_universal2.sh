# game/app specific values
export APP_VERSION="1.6"
export PRODUCT_NAME="openxray"
export PROJECT_NAME="xray-16"
export PORT_NAME="openxray"
export ICONSFILENAME="openxray"
export EXECUTABLE_NAME="openxray"
export PKGINFO="APPLOPXR"
export GIT_TAG="1.6"
export GIT_DEFAULT_BRANCH="dev"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

# check out the latest release tag
# echo git checkout tags/${GIT_TAG}
# git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

export MACOSX_DEPLOYMENT_TARGET=10.9

# cd ${X86_64_BUILD_FOLDER}

# cmake \
# -DCMAKE_PREFIX_PATH=/usr/local \
# -DCMAKE_INSTALL_PREFIX=/usr/local \
# -DCMAKE_OSX_ARCHITECTURES=x86_64 \
# -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
# -DCMAKE_C_COMPILER=$(xcrun --sdk macosx --find clang) \
# -DCMAKE_CXX_COMPILER=$(xcrun --sdk macosx --find clang++) \
# -DCMAKE_C_FLAGS="-target x86_64-apple-macos10.7" \
# -DCMAKE_CXX_FLAGS="-target x86_64-apple-macos10.7" \
# ..
# cmake --build . -j $NCPU
# mkdir -p "${EXECUTABLE_FOLDER_PATH}"
# # cp openxray.x86_64 "${EXECUTABLE_FOLDER_PATH}"/"${EXECUTABLE_NAME}"
# # cp omohaaded.x86_64 "${EXECUTABLE_FOLDER_PATH}"/omohaaded
# # cp code/client/cgame/cgame.x86_64.dylib "${EXECUTABLE_FOLDER_PATH}"
# # cp code/server/fgame/game.x86_64.dylib "${EXECUTABLE_FOLDER_PATH}"
# cd ..

cd ${ARM64_BUILD_FOLDER}

cmake \
-DCMAKE_OSX_ARCHITECTURES=arm64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
-DCMAKE_FIND_FRAMEWORK=LAST \
-DLZO_INCLUDE_DIR=/opt/homebrew/include \
-DLZO_LIBRARY=/opt/homebrew/lib/liblzo2.dylib \
..
cmake --build . -j $NCPU
mkdir -p "${EXECUTABLE_FOLDER_PATH}"
# cp openxray.arm64 "${EXECUTABLE_FOLDER_PATH}"/"${EXECUTABLE_NAME}"
# cp omohaaded.arm64 "${EXECUTABLE_FOLDER_PATH}"/omohaaded
# cp code/client/cgame/cgame.arm64.dylib "${EXECUTABLE_FOLDER_PATH}"
# cp code/server/fgame/game.arm64.dylib "${EXECUTABLE_FOLDER_PATH}"
cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

echo lipo /usr/local/opt/openal-soft/lib/libopenal.1.dylib /opt/Homebrew/opt/openal-soft/lib/libopenal.1.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libopenal.1.dylib" -create
lipo /usr/local/opt/openal-soft/lib/libopenal.1.dylib /opt/Homebrew/opt/openal-soft/lib/libopenal.1.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libopenal.1.dylib" -create

cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/*.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/*.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}


#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"