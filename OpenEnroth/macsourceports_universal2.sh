# game/app specific values
export APP_VERSION="0.1"
export PRODUCT_NAME="OpenEnroth"
export PROJECT_NAME="OpenEnroth"
export PORT_NAME="OpenEnroth"
export ICONSFILENAME="OpenEnroth"
export EXECUTABLE_NAME="OpenEnroth"
export PKGINFO="APPLMM7"
export GIT_DEFAULT_BRANCH="master"
export GIT_TAG="v0.9.1"

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
# git checkout tags/${GIT_TAG}rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${BUILT_PRODUCTS_DIR}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    export OpenAL_DIR=/usr/local/opt/openal-soft

    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}
    cd ${ARM64_BUILD_FOLDER}
    cmake \
    -DPKG_CONFIG_EXECUTABLE=/usr/local/bin/pkg-config \
    -DCMAKE_OSX_ARCHITECTURES="arm64" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
    -DCMAKE_PREFIX_PATH=/usr/local \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DOE_BUILD_TESTS=OFF \
    -DOpenAL_DIR=/usr/local/opt/openal-soft \
    ..
    cmake --build . --parallel $NCPU
    # install_name_tool -add_rpath @executable_path/. src/Bin/OpenEnroth/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    # mv src/Bin/OpenEnroth/${WRAPPER_NAME} .

    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}
    cd ${ARM64_BUILD_FOLDER}
    cmake \
    -DPKG_CONFIG_EXECUTABLE=/usr/local/bin/pkg-config \
    -DCMAKE_OSX_ARCHITECTURES="x96_64" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
    -DCMAKE_PREFIX_PATH=/usr/local \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DOE_BUILD_TESTS=OFF \
    -DOpenAL_DIR=/usr/local/opt/openal-soft \
    ..
    cmake --build . --parallel $NCPU
    # install_name_tool -add_rpath @executable_path/. src/Bin/OpenEnroth/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    # mv src/Bin/OpenEnroth/${WRAPPER_NAME} .

else
    export OpenAL_DIR=/opt/homebrew/opt/openal-soft

    # create makefiles with cmake, perform builds with make
    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}
    cd ${ARM64_BUILD_FOLDER}
    cmake  \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
    -DCMAKE_PREFIX_PATH=/opt/Homebrew \
    -DCMAKE_INSTALL_PREFIX=/opt/Homebrew \
    ..
    make -j$NCPU
    mv src/Bin/OpenEnroth/${WRAPPER_NAME} .

    export OpenAL_DIR=/usr/local/opt/openal-soft
    export ZLIB_LIBRARY_RELEASE=/usr/local/lib/libzlibstatic.a

    cd ..
    rm -rf ${X86_64_BUILD_FOLDER}
    mkdir ${X86_64_BUILD_FOLDER}
    cd ${X86_64_BUILD_FOLDER}
    cmake \
    -DPKG_CONFIG_EXECUTABLE=/usr/local/bin/pkg-config \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
    -DCMAKE_PREFIX_PATH=/usr/local \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    ..
    make -j$NCPU
    mv src/Bin/OpenEnroth/${WRAPPER_NAME} .
fi

cd ..

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"
    
    cd ${BUILT_PRODUCTS_DIR}
    install_name_tool -add_rpath @executable_path/. ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    cd ..
else
    "../MSPBuildSystem/common/build_app_bundle.sh"
fi

cp -a resources/shaders ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/shaders

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"