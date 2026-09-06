# game/app specific values
export APP_VERSION="4.0.0"
export PRODUCT_NAME="augustus"
export PROJECT_NAME="augustus"
export PORT_NAME="Augustus"
export ICONSFILENAME="augustus"
export EXECUTABLE_NAME="augustus"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.11"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
cmake "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" ..
cmake --build . --parallel $NCPU
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"