# game/app specific values
export APP_VERSION="0.1.16"
export PRODUCT_NAME="PvZ-Portable"
export PROJECT_NAME="PvZ-Portable"
export PORT_NAME="PvZ-Portable"
export ICONSFILENAME="PvZ-Portable"
export EXECUTABLE_NAME="pvz-portable"
export PKGINFO="APPLPVZP"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="13.3"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

gsed -i 's|SDL_GetBasePath()|SDL_GetPrefPath("io.github.wszqkzqk", "PvZPortable")|' src/SexyAppFramework/SexyAppBase.cpp

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=13.3 \
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