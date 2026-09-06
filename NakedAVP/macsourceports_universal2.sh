# game/app specific values
export APP_VERSION="1.2.2"
export PRODUCT_NAME="NakedAVP"
export PROJECT_NAME="NakedAVP"
export PORT_NAME="NakedAVP"
export ICONSFILENAME="NakedAVP"
export EXECUTABLE_NAME="avp"
export PKGINFO="APPLAVP"

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

# Tweak until/unless fixed (this file needs to know about SDL.h)
gsed -i '1 i\#include <SDL3/SDL.h>' src/avp/win95/frontend/avp_menus.c

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DCMAKE_C_FLAGS="-Wno-error=incompatible-function-pointer-types -I/usr/local/include/" \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
-DOPENAL_LIBRARY=/usr/local/lib/libopenal.dylib \
-DOPENAL_INCLUDE_DIR=/usr/local/include/AL \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
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