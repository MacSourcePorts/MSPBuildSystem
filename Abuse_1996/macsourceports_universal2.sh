# game/app specific values
export APP_VERSION="0.9a"
export PRODUCT_NAME="abuse"
export PROJECT_NAME="Abuse_1996"
export PORT_NAME="Abuse_1996"
export ICONSFILENAME="abuse"
export EXECUTABLE_NAME="abuse"
export PKGINFO="APPLABUS"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DMACOS_APP_BUNDLE=ON \
-DCMAKE_CXX_FLAGS="-Wno-c++11-narrowing" \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
..
# make -j$NCPU
cmake --build . --parallel $NCPU
mv src/${WRAPPER_NAME} .
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data
cp -a ../../MSPBuildSystem/${PROJECT_NAME}/data/* ${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"