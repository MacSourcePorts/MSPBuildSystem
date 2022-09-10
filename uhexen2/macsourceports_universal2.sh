# This file is for the GL version of Hexen II. 
# This one works fine on Apple Silicon

# game/app specific values
export APP_VERSION="1.5.9-sw"
export PRODUCT_NAME="uhexen2-sw"
export PROJECT_NAME="uhexen2"
export PORT_NAME="uHexen2"
export ICONSFILENAME="uhexen2"
export EXECUTABLE_NAME="hexen2"
export PKGINFO="APPLHXN2"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

# this port is not HiDPI aware
export HIGH_RESOLUTION_CAPABLE="false"

cd ../../${PROJECT_NAME}

# reset to the main branch
# echo git checkout ${GIT_DEFAULT_BRANCH}
# git checkout ${GIT_DEFAULT_BRANCH}

# # fetch the latest 
# echo git pull
# git pull

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake, perform builds with make
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd engine/hexen2
make clean
make MACH_TYPE=x86_64 -j8 h2
cp hexen2 ../../${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd ../../

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd engine/hexen2
make clean
make MACH_TYPE=arm64 -j8 h2
cp hexen2 ../../${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd ../../

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"