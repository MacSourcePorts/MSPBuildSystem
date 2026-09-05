# game/app specific values
export APP_VERSION="3.0"
export PRODUCT_NAME="opentyrian2000"
export PROJECT_NAME="opentyrian2000"
export PORT_NAME="OpenTyrian2000"
export ICONSFILENAME="opentyrian2000"
export EXECUTABLE_NAME="opentyrian2000"
export PKGINFO="APPLTYR2K"
export GIT_TAG="v2000.20200917"
export GIT_DEFAULT_BRANCH="main"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data"

make clean
(ARCH="arm64 -arch x86_64" PKG_CONFIG=/usr/local/bin/pkg-config make -j8)
mv ${EXECUTABLE_NAME} "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
"../MSPBuildSystem/common/copy_dependencies.sh" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
cp -a "data/." "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data"

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"