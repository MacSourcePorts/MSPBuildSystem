# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="openjazz"
export PROJECT_NAME="openjazz"
export PORT_NAME="openjazz"
export ICONSFILENAME="openjazz"
export EXECUTABLE_NAME="OpenJazz"
export PKGINFO="APPLOJJ1"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
-DSDLMAIN_LIBRARY=/usr/local/lib/libSDL2main.a \
-DSDL_INCLUDE_DIR=/usr/local/include/SDL2 \
-DSDL_LIBRARY="/usr/local/lib/libSDL2main.a;/usr/local/lib/libSDL2.dylib;-framework Cocoa" \
..
cmake --build . -j $NCPU
cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"