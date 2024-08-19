# game/app specific values
export APP_VERSION="0.9a"
export PRODUCT_NAME="abuse"
export PROJECT_NAME="Abuse_1996"
export PORT_NAME="Abuse_1996"
export ICONSFILENAME="abuse"
export EXECUTABLE_NAME="abuse"
export PKGINFO="APPLABUS"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    mkdir ${BUILT_PRODUCTS_DIR}
    cd ${BUILT_PRODUCTS_DIR}
    cmake \
    -DMACOS_APP_BUNDLE=ON \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
    -DCMAKE_PREFIX_PATH=/usr/local \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    ..
    # make -j$NCPU
    cmake --build . --parallel $NCPU
    mv src/${WRAPPER_NAME} .
    install_name_tool -add_rpath @executable_path/. ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    cp /usr/local/lib/libSDL2-2.0.0.dylib ${EXECUTABLE_FOLDER_PATH}
    cp /usr/local/lib/libSDL2_mixer-2.0.801.0.0.dylib ${EXECUTABLE_FOLDER_PATH}
    mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data
    cp -a ../data/* ${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data
else
    # create makefiles with cmake, perform builds with make
    rm -rf ${X86_64_BUILD_FOLDER}
    mkdir ${X86_64_BUILD_FOLDER}
    cd ${X86_64_BUILD_FOLDER}
    cmake \
    -DMACOS_APP_BUNDLE=ON \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
    -DCMAKE_PREFIX_PATH=/usr/local \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    ..
    make -j$NCPU
    mv src/${WRAPPER_NAME} .
    mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data
    cp -a ../data/* ${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data

    cd ..
    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}
    cd ${ARM64_BUILD_FOLDER}
    cmake  \
    -DMACOS_APP_BUNDLE=ON \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
    -DCMAKE_PREFIX_PATH=/opt/Homebrew \
    -DCMAKE_INSTALL_PREFIX=/opt/Homebrew \
    ..
    make -j$NCPU
    mv src/${WRAPPER_NAME} .
fi

cd ..

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"
else
    "../MSPBuildSystem/common/build_app_bundle.sh"
fi

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"