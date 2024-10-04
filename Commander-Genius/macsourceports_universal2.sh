# game/app specific values
export APP_VERSION="3.5.1"
export PRODUCT_NAME="CGenius"
export PROJECT_NAME="Commander-Genius"
export PORT_NAME="Commander Genius"
export ICONSFILENAME="cglogo"
export EXECUTABLE_NAME="CGeniusExe"
export PKGINFO="APPLCKEN"
export GIT_TAG="v3.5.1"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

if [ -n "$3" ]; then
	export APP_VERSION="${3/v/}"
	export GIT_TAG="$3"
	echo "Setting version / tag to : " "$APP_VERSION" / "$GIT_TAG"
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

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    mkdir ${BUILT_PRODUCTS_DIR}
    mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
    cd ${BUILT_PRODUCTS_DIR}

    cmake \
    -DMACOS_APP_BUNDLE=ON \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
    -DCMAKE_PREFIX_PATH=/usr/local \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    ..
    cmake --build . --parallel $NCPU
    install_name_tool -add_rpath @executable_path/. src/${EXECUTABLE_NAME}
    cp src/${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
    "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
else
    rm -rf ${X86_64_BUILD_FOLDER}
    mkdir ${X86_64_BUILD_FOLDER}
    mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
    cd ${X86_64_BUILD_FOLDER}
    cmake \
    -DMACOS_APP_BUNDLE=ON \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
    -DCMAKE_PREFIX_PATH=/usr/local \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    ..
    make -j$NCPU
    cp src/${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}

    cd ..
    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}
    mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
    cd ${ARM64_BUILD_FOLDER}
    cmake  \
    -DMACOS_APP_BUNDLE=ON \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
    -DCMAKE_PREFIX_PATH=/opt/Homebrew \
    -DCMAKE_INSTALL_PREFIX=/opt/Homebrew \
    ..
    make -j$NCPU
    cp src/${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
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