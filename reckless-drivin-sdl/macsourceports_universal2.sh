# game/app specific values
export APP_VERSION="1.0.3"
export PRODUCT_NAME="RecklessDrivin"
export PROJECT_NAME="reckless-drivin-sdl"
export PORT_NAME="reckless-drivin-sdl"
export ICONSFILENAME="reckless-drivin-sdl"
export EXECUTABLE_NAME="RecklessDrivin"
export PKGINFO="APPLRD"
export GIT_DEFAULT_BRANCH="main"
export GIT_TAG="v1.0.3"

#constants
source ../common/constants.sh

# this port is not HiDPI aware
export HIGH_RESOLUTION_CAPABLE="false"

cd ../../${PROJECT_NAME}

if [ -n "$3" ]; then
	export APP_VERSION="${3/v/}"
	export GIT_TAG="$3"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"

    # reset to the main branch
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}

    # fetch the latest 
    echo git pull
    git pull
fi

rm -rf build
rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}

./build-mac-app.sh

# mv build/${WRAPPER_NAME} ${BUILT_PRODUCTS_DIR}
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