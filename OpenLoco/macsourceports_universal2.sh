# game/app specific values
export APP_VERSION="25.12"
export PRODUCT_NAME="OpenLoco"
export PROJECT_NAME="OpenLoco"
export PORT_NAME="OpenLoco"
export ICONSFILENAME="OpenLoco"
export EXECUTABLE_NAME="OpenLoco"
export PKGINFO="APPLBGDM"
export GIT_DEFAULT_BRANCH="master"
export GIT_TAG="v25.12"

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

mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DOPENLOCO_BUILD_TESTS=OFF \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
..
cmake --build . --parallel $NCPU
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"