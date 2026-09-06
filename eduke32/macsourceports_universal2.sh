# game/app specific values
export APP_VERSION="2.0"
export PRODUCT_NAME="eduke32"
export PROJECT_NAME="eduke32"
export PORT_NAME="EDuke32"
export ICONSFILENAME="eduke32"
export EXECUTABLE_NAME="eduke32"
export PKGINFO="APPLED32"

#constants
source ../common/constants.sh
export STRIP=/usr/bin/strip

cd ../../${PROJECT_NAME}

# If we're on the build server, then we assume we have the latest
# code and we need to copy over our build tweaks
cp "../MSPBuildSystem/EDuke32/Common.mak" .
cp "../MSPBuildSystem/EDuke32/osxbuild.sh" ./platform

# skipping the checkout bit until the EDuke32 project builds latest on Mac

#fix resolution on cocoa window
export HIGH_RESOLUTION_CAPABLE="true"

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
cd platform
./osxbuild.sh --buildppc=0 --build86=0 --build64=1 --buildarm64=1 --debug=0 --main=1 --tools=0 --pack=0
cd ..
mv package/${PRODUCT_NAME}.app ${BUILT_PRODUCTS_DIR}
"../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"