# game/app specific values
export APP_VERSION="1.12"
export PRODUCT_NAME="wrathplaces"
export PROJECT_NAME="wrathplaces"
export PORT_NAME="wrathplaces"
export ICONSFILENAME="wrathplaces"
export EXECUTABLE_NAME="wrath"
export PKGINFO="APPLWRTH"
export GIT_TAG="1.12"
export GIT_DEFAULT_BRANCH="master"
export ENTITLEMENTS_FILE="../MSPBuildSystem/wrathplaces/wrathplaces.entitlements"

# constants
source ../common/constants.sh
source ../common/signing_values.local
export MINIMUM_SYSTEM_VERSION="10.9"
export STRIP=/usr/bin/strip

cd ../../${PROJECT_NAME}
# because we maintain this project and it's rare that it will ever change
# we're going to skip the whole part with git

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
make clean
(ARCH=x86_64 LIB_DIR=/usr/local/lib/ make sdl2-release -j$NCPU)
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mv ${EXECUTABLE_NAME} ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
make clean
(ARCH=arm64 LIB_DIR=/usr/local/lib/ make sdl2-release -j$NCPU)
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mv ${EXECUTABLE_NAME} ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"

cd ${BUILT_PRODUCTS_DIR}
install_name_tool -add_rpath @executable_path/. "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
"../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
cd ..

# we're doing things the hard way here because these aren't linked in but they need to be in the same dir
cp /usr/local/lib/libvorbis.dylib ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cp /usr/local/lib/libvorbisfile.dylib  ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cp /usr/local/lib/libogg.dylib  ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cp /usr/local/lib/libtheora.dylib  ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cp /usr/local/lib/libvorbisenc.dylib  ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cp /usr/local/lib/libfreetype.dylib  ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cp /usr/local/lib/libpng16.16.dylib  ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cp /usr/local/lib/libjpeg.dylib  ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbis.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisfile.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libogg.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libtheora.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisenc.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libfreetype.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libpng16.16.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libjpeg.dylib

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"