# game/app specific values
export APP_VERSION="2.1.20221123"
export PRODUCT_NAME="opentyrian"
export PROJECT_NAME="opentyrian"
export PORT_NAME="OpenTyrian"
export ICONSFILENAME="opentyrian"
export EXECUTABLE_NAME="opentyrian"
export PKGINFO="APPLTYR"
export GIT_TAG="v2.1.20221123"
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

# check out the latest release tag
#echo git checkout tags/${GIT_TAG}
#git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
mkdir -p "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}"
mkdir -p "${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data"
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
mkdir -p "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}"
mkdir -p "${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data"

make clean
(ARCH=x86_64 PKG_CONFIG=/usr/local/bin/pkg-config make -j8)
mv ${EXECUTABLE_NAME} "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}"
cp -a "data/." "${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data"

make clean
(ARCH=arm64 PKG_CONFIG=/opt/homebrew/bin/pkg-config make -j8)
mv ${EXECUTABLE_NAME} "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}"
cp -a "data/." "${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data"

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"