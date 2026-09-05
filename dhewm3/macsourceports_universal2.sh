# game/app specific values
export APP_VERSION="1.5.4"
export PRODUCT_NAME="dhewm3"
export PROJECT_NAME="dhewm3"
export PORT_NAME="dhewm3"
export ICONSFILENAME="doom3"
export EXECUTABLE_NAME="dhewm3"
export PKGINFO="APPLDHM3"
export GIT_TAG="1.5.4"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

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
cmake -G "Unix Makefiles" "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 -DSDL2=ON -DOPENAL_LIBRARY=/usr/local/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/usr/local/include ../neo -Wno-dev
cmake --build . --parallel $NCPU
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

#create any app-specific directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base" || exit 1;
fi

#lipo any app-specific things
cp ${BUILT_PRODUCTS_DIR}/base.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base/"
cp ${BUILT_PRODUCTS_DIR}/d3xp.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base/"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"