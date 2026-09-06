# game/app specific values
export APP_VERSION="1.0-ao"
export PRODUCT_NAME="relive-ao"
export PROJECT_NAME="alive_reversing"
export PORT_NAME="R.E.L.I.V.E. AO"
export ICONSFILENAME="oddworld-ao"
export EXECUTABLE_NAME="relive"
export PKGINFO="APPLOWAO"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.15"

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
-DCMAKE=/usr/local/bin/cmake \
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
-DCMAKE_C_FLAGS="-Wno-error=single-bit-bitfield-constant-conversion -Wno-error=unused-but-set-variable" \
..
cmake --build . --parallel $NCPU
cp Source/relive/${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"