# game/app specific values
export APP_VERSION="0.9.1"
export PRODUCT_NAME="RigelEngine"
export PROJECT_NAME="RigelEngine"
export PORT_NAME="RigelEngine"
export ICONSFILENAME="RigelEngine"
export EXECUTABLE_NAME="RigelEngine"
export PKGINFO="APPLROTT"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.15"

cd ../../${PROJECT_NAME}

export AR=/usr/bin/ar
export RANLIB=/usr/bin/ranlib

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
..
cmake --build . --parallel $NCPU
mv src/${WRAPPER_NAME} .

cd ..

"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"