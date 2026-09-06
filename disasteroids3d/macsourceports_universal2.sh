# game/app specific values
export APP_VERSION="1.4.0"
export PRODUCT_NAME="disasteroids3d"
export PROJECT_NAME="disasteroids3d"
export PORT_NAME="Disasteroids 3d"
export ICONSFILENAME="disasteroids3d"
export EXECUTABLE_NAME="disasteroids3d"
export PKGINFO="APPLD3D"

# constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}
# because we maintain this project and it's rare that it will ever change
# we're going to skip the whole part with git

rm -rf ${BUILT_PRODUCTS_DIR}

# create folders for make
rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}

# perform builds with make
(ARCH="arm64 -arch x86_64" OUTPUT_FOLDER=release SDL2_INCLUDE=/usr/local/include/SDL2 SDL2_LIB=/usr/local/lib make -j$NCPU)
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
mv ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
"../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

#create any app-specific directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Res" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Res" || exit 1;
fi

cp Res/* "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Res"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"