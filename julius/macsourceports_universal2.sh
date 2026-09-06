# game/app specific values
export APP_VERSION="1.7.0"
export PRODUCT_NAME="julius"
export PROJECT_NAME="julius"
export PORT_NAME="Julius"
export ICONSFILENAME="julius"
export EXECUTABLE_NAME="julius"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.10"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake, perform builds with make
mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
cmake -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ..
cmake --build . --parallel $NCPU
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"