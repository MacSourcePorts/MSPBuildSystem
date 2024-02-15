# game/app specific values
export APP_VERSION="1.2.12"
export PRODUCT_NAME="bstone"
export PROJECT_NAME="bstone"
export PORT_NAME="bstone"
export ICONSFILENAME="bstone"
export EXECUTABLE_NAME="bstone"
export PKGINFO="APPLROTT"
export GIT_DEFAULT_BRANCH="develop"

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
cd ${X86_64_BUILD_FOLDER}
cmake \
-DMACOS_APP_BUNDLE=ON \
-DCMAKE_OSX_ARCHITECTURES=x86_64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
-DCMAKE_CXX_STANDARD=11 \
..
make -j$NCPU
cp src/${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd ${ARM64_BUILD_FOLDER}
cmake  \
-DMACOS_APP_BUNDLE=ON \
-DCMAKE_OSX_ARCHITECTURES=arm64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/opt/Homebrew \
-DCMAKE_INSTALL_PREFIX=/opt/Homebrew \
-DCMAKE_CXX_STANDARD=11 \
..
make -j$NCPU
cp src/${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"