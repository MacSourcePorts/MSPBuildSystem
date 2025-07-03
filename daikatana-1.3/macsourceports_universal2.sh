# game/app specific values
export APP_VERSION="1.3"
export PRODUCT_NAME="daikatana"
export PROJECT_NAME="daikatana-1.3"
export PORT_NAME="Daikatana 1.3 Project"
export ICONSFILENAME="daikatana"
export EXECUTABLE_NAME="daikatana"
export PKGINFO="APPLDKTNA"

export RANLIB=/usr/bin/ranlib
export AR=/usr/bin/ar


# constants
source ../common/constants.sh
source ../common/signing_values.local
export MINIMUM_SYSTEM_VERSION="10.9"

# Main game compilation
cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

set -e

./gengitdate.sh

make clean
(OSTYPE=macos MACHTYPE=x86_64 GAME_STATIC=1 REF_STATIC_GL=1 AUDIO_STATIC_OPENAL=1 make STD_CXX=clang++)
(OSTYPE=macos MACHTYPE=arm64 GAME_STATIC=1 REF_STATIC_GL=1 AUDIO_STATIC_OPENAL=1 make STD_CXX=clang++)

cd bin/release-x86_64
mkdir -p "${EXECUTABLE_FOLDER_PATH}"
cp "${EXECUTABLE_NAME}" "${EXECUTABLE_FOLDER_PATH}"

mkdir -p "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls" || exit 1;
cp dlls/* "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls" || exit 1;

install_name_tool -change ../../bin/release-x86_64/dlls/minizip.dylib @executable_path/../Resources/dlls/minizip.dylib ${EXECUTABLE_FOLDER_PATH}/daikatana
cd ../..

cd bin/release-arm64
mkdir -p "${EXECUTABLE_FOLDER_PATH}"
cp "${EXECUTABLE_NAME}" "${EXECUTABLE_FOLDER_PATH}"

mkdir -p "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls" || exit 1;
cp dlls/* "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls" || exit 1;

# # dylibbundler needs a little nudge on these
install_name_tool -change ../../bin/release-arm64/dlls/minizip.dylib @executable_path/../Resources/dlls/minizip.dylib ${EXECUTABLE_FOLDER_PATH}/daikatana
cd ../..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"

#create any app-specific directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" || exit 1;
fi

if [ ! -d "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls" || exit 1;
fi

if [ ! -d "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data" || exit 1;
fi

cp -a ../MSPBuildSystem/${PROJECT_NAME}/patchdata/data/* ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data

#lipo the executable
lipo bin/release-x86_64/"${EXECUTABLE_FOLDER_PATH}"/daikatana bin/release-arm64/"${EXECUTABLE_FOLDER_PATH}"/daikatana -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/daikatana" -create
lipo bin/release-x86_64/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/dlls/ioncommon.dylib bin/release-arm64/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/dlls/ioncommon.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/ioncommon.dylib" -create
lipo bin/release-x86_64/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/dlls/language_english.dylib bin/release-arm64/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/dlls/language_english.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/language_english.dylib" -create
lipo bin/release-x86_64/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/dlls/minizip.dylib bin/release-arm64/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/dlls/minizip.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/minizip.dylib" -create

cd ${BUILT_PRODUCTS_DIR}
install_name_tool -add_rpath @executable_path/. "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
"../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
"../../MSPBuildSystem/common/copy_dependencies.sh" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/ioncommon.dylib"
"../../MSPBuildSystem/common/copy_dependencies.sh" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/language_english.dylib"
"../../MSPBuildSystem/common/copy_dependencies.sh" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/minizip.dylib"
cd ..

#sign and notarize
echo codesign --force --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/ioncommon.dylib
codesign --force --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/ioncommon.dylib

echo codesign --force --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/minizip.dylib
codesign --force --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/minizip.dylib

echo codesign --force --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/language_english.dylib
codesign --force --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/language_english.dylib

export ENTITLEMENTS_FILE="base/Daikatana/Daikatana.entitlements"
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"