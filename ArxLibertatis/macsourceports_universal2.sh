# game/app specific values
export APP_VERSION="1.2.1"
export PRODUCT_NAME="ArxLibertatis"
export PROJECT_NAME="ArxLibertatis"
export PORT_NAME="Arx Libertatis"
export ICONSFILENAME="ArxLibertatis"
export EXECUTABLE_NAME="arx"
export PKGINFO="APPLARX"
export GIT_TAG="1.2.1"
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

# create makefiles with cmake, perform builds with make
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd ${X86_64_BUILD_FOLDER}
cmake \
-DCMAKE_OSX_ARCHITECTURES=x86_64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
..
make
mv arx ${EXECUTABLE_FOLDER_PATH}

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd ${ARM64_BUILD_FOLDER}
cmake  \
-DCMAKE_OSX_ARCHITECTURES=arm64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/opt/Homebrew \
-DCMAKE_INSTALL_PREFIX=/opt/Homebrew \
..
make
mv arx ${EXECUTABLE_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"