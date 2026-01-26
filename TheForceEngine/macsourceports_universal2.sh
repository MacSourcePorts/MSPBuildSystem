# game/app specific values
export APP_VERSION="1.22.420"
export PRODUCT_NAME="TheForceEngine"
export PROJECT_NAME="TheForceEngine"
export PORT_NAME="TheForceEngine"
export ICONSFILENAME="TheForceEngine"
export EXECUTABLE_NAME="theforceengine_osx"
export PKGINFO="APPLTFE"
export GIT_DEFAULT_BRANCH="main"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.7"

cd ../../${PROJECT_NAME}

if [ -n "$3" ]; then
	export APP_VERSION="${3/v/}"
	export GIT_TAG="$3"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"

    # reset to the main branch
    # echo git checkout ${GIT_DEFAULT_BRANCH}
    # git checkout ${GIT_DEFAULT_BRANCH}

    # # fetch the latest 
    # echo git pull
    # git pull
fi

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
..
cmake --build . --parallel $NCPU
cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}/
cp -RL Captions ${EXECUTABLE_FOLDER_PATH}/
cp -RL Documentation ${EXECUTABLE_FOLDER_PATH}/
cp -RL EditorDef ${EXECUTABLE_FOLDER_PATH}/
cp -RL ExternalData ${EXECUTABLE_FOLDER_PATH}/
cp -RL Fonts ${EXECUTABLE_FOLDER_PATH}/
cp -RL Mods ${EXECUTABLE_FOLDER_PATH}/
cp -RL Shaders ${EXECUTABLE_FOLDER_PATH}/
cp -RL SoundFonts ${EXECUTABLE_FOLDER_PATH}/
cp -RL Tests ${EXECUTABLE_FOLDER_PATH}/
cp -RL UI_Images ${EXECUTABLE_FOLDER_PATH}/
cp -RL UI_Text ${EXECUTABLE_FOLDER_PATH}/
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"