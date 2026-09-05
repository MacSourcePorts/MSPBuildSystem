# game/app specific values
export APP_VERSION="1.6.2"
export PRODUCT_NAME="BDD3"
export PROJECT_NAME="aviaozinhoachievements"
export PORT_NAME="BDD3"
export ICONSFILENAME="bdd3"
export EXECUTABLE_NAME="AVIAO3GAME"
export PKGINFO="APPLBDD3"
export GIT_DEFAULT_BRANCH="main"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.7"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	export GIT_TAG="$2"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"
fi

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DQS_PREFIX=/usr/local \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
..
cmake --build . --parallel $NCPU
cp ../Build/${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"