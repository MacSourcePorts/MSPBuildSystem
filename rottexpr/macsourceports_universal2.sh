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
export MINIMUM_SYSTEM_VERSION="10.9"

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

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    mkdir ${BUILT_PRODUCTS_DIR}
    mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}

    cd src
    make clean
    (RANLIB=/usr/bin/ranlib AR=/usr/bin/ar CFLAGS="-I/usr/local/include/ -arch arm64 -arch x86_64 -mmacosx-version-min=10.9" LDFLAGS="-L/usr/local/lib/ -mmacosx-version-min=10.9 -headerpad_max_install_names" make) || exit 1;
    cd ..
    mkdir -p ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}"
    mv src/"${EXECUTABLE_NAME}" ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}"
    "../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
else
    cd src
    make clean
    (CFLAGS="-I/opt/homebrew/include/ -arch arm64 -mmacosx-version-min=10.9" LDFLAGS="-L/opt/homebrew/lib/ -mmacosx-version-min=10.9" make) || exit 1;
    cd ..
    mkdir -p ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
    mv src/"${EXECUTABLE_NAME}" ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"

    cd src
    make clean
    (CFLAGS="-I/usr/local/include/ -arch x86_64 -mmacosx-version-min=10.9" LDFLAGS="-L/usr/local/lib/ -mmacosx-version-min=10.9" make) || exit 1;
    cd ..
    mkdir -p ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
    mv src/"${EXECUTABLE_NAME}" ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
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