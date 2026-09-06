# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="OpenXcom"
export PROJECT_NAME="OpenXcom"
export PORT_NAME="OpenXcom"
export ICONSFILENAME="OpenXcom"
export EXECUTABLE_NAME="openxcom"
export PKGINFO="APPLXCOM"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.12"

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

# tweak one file
gsed -i 's|postprocess_bundle|# postprocess_bundle|' src/CMakeLists.txt

mkdir ${BUILT_PRODUCTS_DIR}

cmake \
-DCMAKE_BUILD_TYPE=Debug \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-B ${BUILT_PRODUCTS_DIR} .

cmake --build ${BUILT_PRODUCTS_DIR} -j$NCPU
"../MSPBuildSystem/common/copy_dependencies.sh" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# copy over sdl2 manually as shim for sdl12-compat
cp /usr/local/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"