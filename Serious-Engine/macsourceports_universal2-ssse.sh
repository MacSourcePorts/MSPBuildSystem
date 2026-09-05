# game/app specific values
export APP_VERSION="ssse-1.1"
export PRODUCT_NAME="ssam-tse"
export PROJECT_NAME="Serious-Engine"
export PORT_NAME="Serious Engine"
export ICONSFILENAME="ssse"
export EXECUTABLE_NAME="ssam"
export PKGINFO="APPLSSSE"
export GIT_TAG="1.5.2"
export GIT_DEFAULT_BRANCH="master"
export ENTITLEMENTS_FILE="../MSPBuildSystem/Serious-Engine/Serious-Engine.entitlements"

#constants
source ../common/constants.sh
source ../common/signing_values.local
export MINIMUM_SYSTEM_VERSION="10.15"

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_CXX_FLAGS="-Wno-error=enum-constexpr-conversion" \
-DCMAKE_CXX_STANDARD=17 \
-DCMAKE_CXX_STANDARD_REQUIRED=ON \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
../Sources
mkdir -p ${EXECUTABLE_FOLDER_PATH}
mkdir -p ${FRAMEWORKS_FOLDER_PATH}
mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cmake --build . --parallel $NCPU
cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
cp Debug/* ${UNLOCALIZED_RESOURCES_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

cp /usr/local/lib/libvorbis.0.4.9.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbis.dylib"
cp /usr/local/lib/libvorbisfile.3.3.8.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisfile.dylib"
cp /usr/local/lib/libogg.0.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libogg.dylib"
cp /usr/local/lib/libvorbisenc.2.0.12.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisenc.dylib"
install_name_tool -change @rpath/libvorbis.0.4.9.dylib @rpath/libvorbis.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisfile.dylib
install_name_tool -change @rpath/libvorbis.0.4.9.dylib @rpath/libvorbis.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisenc.dylib
install_name_tool -change @rpath/libogg.0.dylib @rpath/libogg.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisfile.dylib
install_name_tool -change @rpath/libogg.0.dylib @rpath/libogg.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbis.dylib
install_name_tool -change @rpath/libogg.0.dylib @rpath/libogg.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisenc.dylib

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbis.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisfile.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libogg.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisenc.dylib

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libEntitiesMP.dylib"
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libGameMP.dylib"
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libShaders.dylib"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"