# game/app specific values
export APP_VERSION="1.0.3"
export PRODUCT_NAME="RecklessDrivin"
export PROJECT_NAME="reckless-drivin-sdl"
export PORT_NAME="reckless-drivin-sdl"
export ICONSFILENAME="reckless-drivin-sdl"
export EXECUTABLE_NAME="RecklessDrivin"
export PKGINFO="APPLRD"

#constants
source ../common/constants.sh

# this port is not HiDPI aware
export HIGH_RESOLUTION_CAPABLE="false"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf build
rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}

./build-mac-app.sh

mv build/Reckless\ Drivin\'.app ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}
cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"