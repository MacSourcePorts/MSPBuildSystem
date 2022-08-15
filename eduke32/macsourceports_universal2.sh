# game/app specific values
export APP_VERSION="2.0"
export PRODUCT_NAME="EDuke32"
export PROJECT_NAME="EDuke32"
export PORT_NAME="EDuke32"
export ICONSFILENAME="eduke32"
export EXECUTABLE_NAME="eduke32"
export PKGINFO="APPLED32"
export COPYRIGHT_TEXT="Eduke32 © 2022 EDuke32 Project."
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

# skipping the checkout bit until the EDuke32 project builds latest on Mac

#fix resolution on cocoa window
export HIGH_RESOLUTION_CAPABLE="true"

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}

cd platform
./osxbuild.sh --buildppc=0 --build86=0 --build64=1 --buildarm64=0 --debug=0 --main=1 --tools=0 --pack=0
cd ..

mv package/${PRODUCT_NAME}.app ${X86_64_BUILD_FOLDER}

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

cd platform
./osxbuild.sh --buildppc=0 --build86=0 --build64=0 --buildarm64=1 --debug=0 --main=1 --tools=0 --pack=0
cd ..

mv package/${PRODUCT_NAME}.app ${ARM64_BUILD_FOLDER}

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"