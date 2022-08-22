# game/app specific values
export APP_VERSION="0.8.0"
export ICONSFILENAME="uqm"
export PROJECT_NAME="uqm"
export PRODUCT_NAME="The Ur-Quan Masters"
export PORT_NAME="uqm"
export EXECUTABLE_NAME="The Ur-Quan Masters"
export PKGINFO="APPLMLST"
export GIT_DEFAULT_BRANCH="main"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

./build.sh uqm clean
(PKG_CONFIG_PATH=/usr/local/lib/pkgconfig CFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib" ARCH=x86_64 ./build.sh uqm -j8)
build/unix_installer/copy_mac_frameworks.pl
mv "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/packages/uqm-0.8.0-3domusic.uqm" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/addons"
mv "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/packages/uqm-0.8.0-voice.uqm" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/addons"
mv "${WRAPPER_NAME}" ${X86_64_BUILD_FOLDER}

./build.sh uqm clean
(ARCH=arm64 ./build.sh uqm -j8)
build/unix_installer/copy_mac_frameworks.pl
mv "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/packages/uqm-0.8.0-3domusic.uqm" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/addons"
mv "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/packages/uqm-0.8.0-voice.uqm" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/addons"
mv "${WRAPPER_NAME}" ${ARM64_BUILD_FOLDER}

# create the app bundle
export BUNDLE_ID="com.macsourceports.uqm"
"../MSPBuildSystem/common/build_app_bundle.sh"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"