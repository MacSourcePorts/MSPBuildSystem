# game/app specific values
export APP_VERSION="0.0.3"
export PRODUCT_NAME="texview"
export PROJECT_NAME="texview"
export PORT_NAME="texview"
export ICONSFILENAME="texview"
export EXECUTABLE_NAME="texview"
export PKGINFO="APPLTXVW"
export GIT_DEFAULT_BRANCH="dev"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	echo "Skipping git because we're on the build server"
else
    # reset to the main branch
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}

    # fetch the latest 
    echo git pull
    git pull
fi

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
../src
cmake --build . --parallel $NCPU
cp texview ${EXECUTABLE_FOLDER_PATH}
cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"