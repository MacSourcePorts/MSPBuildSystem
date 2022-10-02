# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="wrathplaces"
export PROJECT_NAME="wrathplaces"
export PORT_NAME="wrathplaces"
export ICONSFILENAME="wrathplaces"
export EXECUTABLE_NAME="wrath"
export PKGINFO="APPLWRTH"
export GIT_TAG="1.0"
export GIT_DEFAULT_BRANCH="master"

# constants
source ../common/constants.sh
source ../common/signing_values.local

cd ../../${PROJECT_NAME}
# because we maintain this project and it's rare that it will ever change
# we're going to skip the whole part with git

rm -rf ${BUILT_PRODUCTS_DIR}

# create folders for make
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

# perform builds with make
make clean
(ARCH=x86_64 LIB_DIR=/usr/local/lib/ make sdl2-release -j$NCPU)
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mv ${EXECUTABLE_NAME} ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}

make clean
(ARCH=arm64 LIB_DIR=/opt/homebrew/lib/ make sdl2-release -j$NCPU)
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mv ${EXECUTABLE_NAME} ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

# lipo any app-specific libraries
# we're doing things the hard way here because these aren't linked in but they need to be in the same dir
lipo /usr/local/lib/libvorbis.dylib /opt/homebrew/lib/libvorbis.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbis.dylib" -create
lipo /usr/local/lib/libvorbisfile.dylib /opt/homebrew/lib/libvorbisfile.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisfile.dylib" -create
lipo /usr/local/lib/libogg.dylib /opt/homebrew/lib/libogg.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libogg.dylib" -create
lipo /usr/local/lib/libtheora.dylib /opt/homebrew/lib/libtheora.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libtheora.dylib" -create
lipo /usr/local/lib/libvorbisenc.dylib /opt/homebrew/lib/libvorbisenc.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisenc.dylib" -create

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbis.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisfile.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libogg.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libtheora.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisenc.dylib

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
# "../MSPBuildSystem/common/package_dmg.sh"