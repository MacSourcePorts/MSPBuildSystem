# game/app specific values
export APP_VERSION="0.2.1"
export PRODUCT_NAME="rawgl"
export PROJECT_NAME="rawgl"
export PORT_NAME="rawgl"
export ICONSFILENAME="rawgl"
export EXECUTABLE_NAME="rawgl"
export PKGINFO="APPLBGDM"
export GIT_DEFAULT_BRANCH="main"

#constants
source ../common/constants.sh
# export MINIMUM_SYSTEM_VERSION="10.14"

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

(LDFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=10.7" CXXFLAGS="-arch arm64 -arch x86_64" make -j$NCPU)
mv ${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
make clean

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"