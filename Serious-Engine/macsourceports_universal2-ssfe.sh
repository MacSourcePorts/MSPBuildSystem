# game/app specific values
export APP_VERSION="ssfe-1.1"
export PRODUCT_NAME="ssam-tfe"
export PROJECT_NAME="Serious-Engine"
export PORT_NAME="Serious Engine"
export ICONSFILENAME="ssfe"
export EXECUTABLE_NAME="ssam-tfe"
export PKGINFO="APPLSSFE"
export GIT_TAG="1.5.2"
export GIT_DEFAULT_BRANCH="master"
export ENTITLEMENTS_FILE="../MSPBuildSystem/Serious-Engine/Serious-Engine.entitlements"

#constants
source ../common/constants.sh
source ../common/signing_values.local

cd ../../${PROJECT_NAME}

# reset to the main branch
# echo git checkout ${GIT_DEFAULT_BRANCH}
# git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
# echo git pull
# git pull

# check out the latest release tag
# NOTE: skipping for now until I do a PR to search in the app bundle for the game files.
# echo git checkout tags/${GIT_TAG}
# git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_OSX_ARCHITECTURES=arm64 ../Sources -DTFE=TRUE
mkdir -p ${EXECUTABLE_FOLDER_PATH}
mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}

cd ..
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_OSX_ARCHITECTURES=x86_64 ../Sources -DTFE=TRUE -DCMAKE_PREFIX_PATH=/usr/local
mkdir -p ${EXECUTABLE_FOLDER_PATH}
mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}

# perform builds with make
cd ..
cd ${ARM64_BUILD_FOLDER}
make -j$NCPU
cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
cp Debug/* ${UNLOCALIZED_RESOURCES_FOLDER_PATH}

cd ..
cd ${X86_64_BUILD_FOLDER}
make -j$NCPU #VERBOSE=1
cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
cp Debug/* ${UNLOCALIZED_RESOURCES_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

# lipo any app-specific libraries
lipo ${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libEntities.dylib ${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libEntities.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libEntities.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libGame.dylib ${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libGame.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libGame.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libShaders.dylib ${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libShaders.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libShaders.dylib" -create

# lipo any app-specific libraries
# we're doing things the hard way here because these aren't linked in but they need to be in the same dir
lipo /usr/local/lib/libvorbis.dylib /opt/homebrew/lib/libvorbis.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbis.dylib" -create
lipo /usr/local/lib/libvorbisfile.dylib /opt/homebrew/lib/libvorbisfile.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisfile.dylib" -create
install_name_tool -change /opt/homebrew/Cellar/libvorbis/1.3.7/lib/libvorbis.0.dylib @executable_path/../Resources/libvorbis.dylib ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisfile.dylib
install_name_tool -change /usr/local/Cellar/libvorbis/1.3.7/lib/libvorbis.0.dylib @executable_path/../Resources/libvorbis.dylib ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisfile.dylib
lipo /usr/local/lib/libogg.dylib /opt/homebrew/lib/libogg.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libogg.dylib" -create
lipo /usr/local/lib/libvorbisenc.dylib /opt/homebrew/lib/libvorbisenc.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisenc.dylib" -create

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbis.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisfile.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libogg.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisenc.dylib

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"