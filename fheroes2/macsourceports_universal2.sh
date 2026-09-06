# game/app specific values
export APP_VERSION="1.1.6"
export PRODUCT_NAME="fheroes2"
export PROJECT_NAME="fheroes2"
export PORT_NAME="fheroes2"
export ICONSFILENAME="fheroes2"
export EXECUTABLE_NAME="fheroes2"
export PKGINFO="APPLFH2"

#constants
source ../common/constants.sh
source ../common/signing_values.local
export MINIMUM_SYSTEM_VERSION="10.15"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}

patch CMakeLists.txt ../MSPBuildSystem/fheroes2/msp.diff
mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DMACOS_APP_BUNDLE=ON \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
..
cmake --build . --parallel $NCPU
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}/h2d
cp ../files/data/resurrection.h2d ${UNLOCALIZED_RESOURCES_FOLDER_PATH}/h2d
mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}/translations
cp ../files/lang/*.mo ${UNLOCALIZED_RESOURCES_FOLDER_PATH}/translations

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"