# game/app specific values
export APP_VERSION="1.32.1"
export PRODUCT_NAME="vkQuake"
export PROJECT_NAME="vkquake"
export PORT_NAME="vkQuake"
export ICONSFILENAME="vkquake"
export EXECUTABLE_NAME="vkquake"
export PKGINFO="APPLVKQ1"
export GIT_TAG="1.32.1"
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
echo git checkout tags/${GIT_TAG}
git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

export MACOSX_DEPLOYMENT_TARGET=10.9

export PATH=/usr/local/bin:$PATH
export LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH
export CPATH=/usr/local/include:$CPATH
/usr/local/bin/meson ${X86_64_BUILD_FOLDER}
ninja -C ${X86_64_BUILD_FOLDER}
mkdir -p ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
mv ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_NAME}" ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"

export PATH=/opt/homebrew/bin:$PATH
export LIBRARY_PATH=/opt/homebrew/lib:$LIBRARY_PATH
export CPATH=/opt/homebrew/include:$CPATH
/opt/Homebrew/bin/meson ${ARM64_BUILD_FOLDER}
ninja -C ${ARM64_BUILD_FOLDER}
mkdir -p ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
mv ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_NAME}" ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"