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

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
    make clean
    (ARCH="x86_64 -arch arm64" PREFIX=/usr/local/bin make -j$NCPU)
    cp ${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
    install_name_tool -add_rpath @executable_path/. ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    "../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
else
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