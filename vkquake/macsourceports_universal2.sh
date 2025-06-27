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
export MINIMUM_SYSTEM_VERSION="10.15"

cd ../../${PROJECT_NAME}

if [ -n "$3" ]; then
	export APP_VERSION="${3/v/}"
	export GIT_TAG="$3"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"

    # reset to the main branch
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}

    # fetch the latest 
    echo git pull
    git pull

    # check out the latest release tag
    echo git checkout tags/${GIT_TAG}
    git checkout tags/${GIT_TAG}
fi

rm -rf ${BUILT_PRODUCTS_DIR}
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    export MACOSX_DEPLOYMENT_TARGET=10.15

    export PATH=/usr/local/bin:$PATH
    export LIBRARY_PATH=/usr/local/lib:$LIBRARY_PATH
    export CPATH=/usr/local/include:$CPATH
    export CFLAGS="-arch arm64"
    export LDFLAGS="-arch arm64"
    meson ${ARM64_BUILD_FOLDER} --cross-file="../MSPBuildSystem/libraries/cross-arm64.txt"
    ninja -C ${ARM64_BUILD_FOLDER}
    mkdir -p ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
    mv ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_NAME}" ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"

    export CFLAGS="-arch x86_64"
    export LDFLAGS="-arch x86_64"
    meson ${X86_64_BUILD_FOLDER} --cross-file="../MSPBuildSystem/libraries/cross-x86_64.txt"
    ninja -C ${X86_64_BUILD_FOLDER}
    mkdir -p ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
    mv ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_NAME}" ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
else 
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
fi

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"
    
    cd ${BUILT_PRODUCTS_DIR}
    "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
    cd ..
else
    "../MSPBuildSystem/common/build_app_bundle.sh"
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"