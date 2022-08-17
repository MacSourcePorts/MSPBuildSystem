# game/app specific values
export APP_VERSION="0.4.1"
export PRODUCT_NAME="OpenRCT2"
export PROJECT_NAME="OpenRCT2"
export PORT_NAME="OpenRCT2"
export ICONSFILENAME="OpenRCT2"
export EXECUTABLE_NAME="OpenRCT2"
export PKGINFO="APPLARX"
export GIT_TAG="v0.4.1"
export GIT_DEFAULT_BRANCH="develop"

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
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake -DCMAKE_INSTALL_PREFIX=./install -DARCH=x86_64 ..
make -j$NCPU install

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -DCMAKE_INSTALL_PREFIX=./install ..
make -j$NCPU install

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

# this is similar to what their create-macos-universal thing does

rsync -ah ${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/* ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
rsync -ah ${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/* ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}

lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -create

# we only do one Frameworks folder since the ones OpenRCT2 supplies are Universal 2 already
echo mkdir -p "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}" || exit 1;
mkdir -p "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}" || exit 1;
rsync -ah --exclude 'libopenrct2.dylib' ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/* ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}

#sign and notarize
export ENTITLEMENTS_FILE="../MSPBuildSystem/OpenRCT2/OpenRCT2.entitlements"
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"