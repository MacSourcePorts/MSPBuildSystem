# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="rottexpr"
export PROJECT_NAME="rottexpr"
export PORT_NAME="rottexpr"
export ICONSFILENAME="rottexpr"
export EXECUTABLE_NAME="rott"
export PKGINFO="APPLROTT"
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

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

cd src
make clean
(CFLAGS="-I/opt/homebrew/include/ -arch arm64 -mmacosx-version-min=10.9" LDFLAGS="-L/opt/homebrew/lib/ -mmacosx-version-min=10.9" make -j$NCPU) || exit 1;
cd ..
mkdir -p ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
mv src/"${EXECUTABLE_NAME}" ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"

cd src
make clean
(CFLAGS="-I/usr/local/include/ -arch x86_64 -mmacosx-version-min=10.9" LDFLAGS="-L/usr/local/lib/ -mmacosx-version-min=10.9" make -j$NCPU) || exit 1;
cd ..
mkdir -p ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
mv src/"${EXECUTABLE_NAME}" ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"