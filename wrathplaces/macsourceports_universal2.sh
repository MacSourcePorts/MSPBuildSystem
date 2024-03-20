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
install_name_tool -change /opt/homebrew/Cellar/libvorbis/1.3.7/lib/libvorbis.0.dylib @executable_path/../Resources/libvorbis.dylib ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisfile.dylib
install_name_tool -change /usr/local/Cellar/libvorbis/1.3.7/lib/libvorbis.0.dylib @executable_path/../Resources/libvorbis.dylib ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisfile.dylib
lipo /usr/local/lib/libogg.dylib /opt/homebrew/lib/libogg.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libogg.dylib" -create
lipo /usr/local/lib/libtheora.dylib /opt/homebrew/lib/libtheora.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libtheora.dylib" -create
lipo /usr/local/lib/libvorbisenc.dylib /opt/homebrew/lib/libvorbisenc.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisenc.dylib" -create
lipo /usr/local/lib/libfreetype.dylib /opt/homebrew/lib/libfreetype.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libfreetype.dylib" -create
install_name_tool -change /opt/homebrew/opt/libpng/lib/libpng16.16.dylib @executable_path/../Resources/libpng16.16.dylib ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libfreetype.dylib
install_name_tool -change /usr/local/opt/libpng/lib/libpng16.16.dylib @executable_path/../Resources/libpng16.16.dylib ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libfreetype.dylib
lipo /usr/local/lib/libpng16.16.dylib /opt/homebrew/lib/libpng16.16.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libpng16.16.dylib" -create
lipo /usr/local/lib/libjpeg.dylib /opt/homebrew/lib/libjpeg.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libjpeg.dylib" -create

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