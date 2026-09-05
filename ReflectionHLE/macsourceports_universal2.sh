# game/app specific values
export APP_VERSION="0.40.1"
export PRODUCT_NAME="reflectionhle"
export PROJECT_NAME="reflectionhle"
export PORT_NAME="ReflectionHLE"
export ICONSFILENAME="reflectionhle"
export EXECUTABLE_NAME="reflectionhle"
export PKGINFO="APPLRHLE"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.15"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	# turns release-20240926 into 20240926
	export APP_VERSION="${2/release-/}"
	export GIT_TAG="$2"
	echo "Setting version / tag to : " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"
fi

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
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