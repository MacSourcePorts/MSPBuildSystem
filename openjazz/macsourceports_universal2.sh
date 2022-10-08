# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="openjazz"
export PROJECT_NAME="openjazz"
export PORT_NAME="openjazz"
export ICONSFILENAME="openjazz"
export EXECUTABLE_NAME="OpenJazz"
export PKGINFO="APPLOJJ1"
export GIT_DEFAULT_BRANCH="dev"

#constants
source ../common/constants.sh

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
make clean
(ARCH=x86_64 PREFIX=/usr/local/bin make -j$NCPU)
cp ${EXECUTABLE_NAME} ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
make clean
(ARCH=arm64 PREFIX=/opt/Homebrew/bin make -j$NCPU)
cp ${EXECUTABLE_NAME} ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# # #create dmg
"../MSPBuildSystem/common/package_dmg.sh"