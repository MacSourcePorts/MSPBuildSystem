# game/app specific values
export APP_VERSION="0.8.0"
export PRODUCT_NAME="dethrace"
export PROJECT_NAME="dethrace"
export PORT_NAME="dethrace"
export ICONSFILENAME="dethrace"
export EXECUTABLE_NAME="dethrace"
export PKGINFO="APPLROTT"
export GIT_DEFAULT_BRANCH="main"
export GIT_TAG="v0.8.0"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.15"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	export GIT_TAG="$2"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"
fi

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_C_FLAGS="-Wno-error=int-conversion" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
..
cmake --build . --parallel $NCPU
cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"