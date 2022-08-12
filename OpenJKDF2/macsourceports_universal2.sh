# game/app specific values
export APP_VERSION="1.2.0"
# this app does its own icons via packaging
export PRODUCT_NAME="OpenJKDF2"
export PROJECT_NAME="OpenJKDF2"
export PORT_NAME="OpenJKDF2"
export EXECUTABLE_NAME="OpenJKDF2"
export PKGINFO="APPLJKDF2"
export GIT_TAG="v0.4.4"
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

#because this port does so much of the packaging itself all we need to do is run the script
./distpkg_macos.sh

mkdir ${BUILT_PRODUCTS_DIR}
mv ${PRODUCT_NAME}_universal.app ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"