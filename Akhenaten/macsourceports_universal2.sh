# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="Akhenaten"
export PROJECT_NAME="Akhenaten"
export PORT_NAME="Akhenaten"
export ICONSFILENAME="akhenaten"
export EXECUTABLE_NAME="Akhenaten"
export GIT_TAG="v1.0"
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
# echo git checkout tags/${GIT_TAG}
# git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake, perform builds with make
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake ..
make -j$NCPU

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake ..
make -j$NCPU

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"