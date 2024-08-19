# game/app specific values
export APP_VERSION="0.6.0"
export PRODUCT_NAME="dethrace"
export PROJECT_NAME="dethrace"
export PORT_NAME="dethrace"
export ICONSFILENAME="dethrace"
export EXECUTABLE_NAME="dethrace"
export PKGINFO="APPLROTT"
export GIT_DEFAULT_BRANCH="main"
export GIT_TAG="v0.6.0"

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

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    # mkdir ${BUILT_PRODUCTS_DIR}
    mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
    cd ${BUILT_PRODUCTS_DIR}
    cmake "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" ..
    cmake --build . --parallel $NCPU
    echo cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
    cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
    install_name_tool -add_rpath @executable_path/. ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    cp /usr/local/lib/libSDL2-2.0.0.dylib ${EXECUTABLE_FOLDER_PATH}
    # cp /usr/local/lib/libfmt.11.dylib ${EXECUTABLE_FOLDER_PATH}
else
    # create makefiles with cmake, perform builds with make
    rm -rf ${X86_64_BUILD_FOLDER}
    mkdir ${X86_64_BUILD_FOLDER}
    mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
    cd ${X86_64_BUILD_FOLDER}
    cmake \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
    -DCMAKE_PREFIX_PATH=/usr/local \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    ..
    make -j$NCPU
    cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}

    cd ..
    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}
    mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
    cd ${ARM64_BUILD_FOLDER}
    cmake  \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
    -DCMAKE_PREFIX_PATH=/opt/Homebrew \
    -DCMAKE_INSTALL_PREFIX=/opt/Homebrew \
    ..
    make -j$NCPU
    cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
fi

cd ..

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"
else
    "../MSPBuildSystem/common/build_app_bundle.sh"
fi

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"