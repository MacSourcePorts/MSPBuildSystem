# game/app specific values
export APP_VERSION="3.0"
export PRODUCT_NAME="opentyrian2000"
export PROJECT_NAME="opentyrian2000"
export PORT_NAME="OpenTyrian2000"
export ICONSFILENAME="opentyrian2000"
export EXECUTABLE_NAME="opentyrian2000"
export PKGINFO="APPLTYR2K"
export GIT_TAG="v2000.20200917"
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

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    mkdir ${BUILT_PRODUCTS_DIR}
    mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
    mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data"

    make clean
    (ARCH="arm64 -arch x86_64" PKG_CONFIG=/usr/local/bin/pkg-config make -j8)
    mv ${EXECUTABLE_NAME} "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
    install_name_tool -add_rpath @executable_path/. "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
    cp /usr/local/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
    cp /usr/local/lib/libSDL2_net-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
    cp -a "data/." "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data"
else
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
fi

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"
else
    "../MSPBuildSystem/common/build_app_bundle.sh"
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"