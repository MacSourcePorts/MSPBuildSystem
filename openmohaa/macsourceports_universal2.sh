# game/app specific values
export APP_VERSION="0.7"
export PRODUCT_NAME="openmohaa"
export PROJECT_NAME="openmohaa"
export PORT_NAME="openmohaa"
export ICONSFILENAME="openmohaa"
export EXECUTABLE_NAME="openmohaa"
export PKGINFO="APPLVKQ1"
export GIT_TAG="0.7"
export GIT_DEFAULT_BRANCH="main"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

export ARM64_PREFIX_PATH=/usr/local
export X86_64_PREFIX_PATH=/opt/Homebrew
export ARM64_AL_PATH=/usr/local/opt/openal-soft
export X86_64_AL_PATH=/opt/Homebrew/opt/openal-soft
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	echo "Skipping git because we're on the build server"
    export PATH=$PATH:~/Library/Python/3.9/bin/
    export ARM64_PREFIX_PATH=/usr/local
    export X86_64_PREFIX_PATH=/usr/local
    export ARM64_AL_PATH=/usr/local
    export X86_64_AL_PATH=/usr/local
else
    # reset to the main branch
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}

    # fetch the latest 
    echo git pull
    git pull

    # check out the latest release tag
    # echo git checkout tags/${GIT_TAG}
    # git checkout tags/${GIT_TAG}
fi

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

export MACOSX_DEPLOYMENT_TARGET=10.9

cd ${X86_64_BUILD_FOLDER}

cmake -G Ninja \
-DOPENAL_INCLUDE_DIR=$X86_64_AL_PATH/include/AL \
-DCMAKE_OSX_ARCHITECTURES=x86_64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=$X86_64_PREFIX_PATH \
-DCMAKE_INSTALL_PREFIX=$X86_64_PREFIX_PATH \
../
ninja
mkdir -p "${EXECUTABLE_FOLDER_PATH}"
cp openmohaa.x86_64 "${EXECUTABLE_FOLDER_PATH}"/"${EXECUTABLE_NAME}"
cp omohaaded.x86_64 "${EXECUTABLE_FOLDER_PATH}"/omohaaded
cp code/client/cgame/cgame.x86_64.dylib "${EXECUTABLE_FOLDER_PATH}"
cp code/server/fgame/game.x86_64.dylib "${EXECUTABLE_FOLDER_PATH}"

cd ../${ARM64_BUILD_FOLDER}

cmake -G Ninja \
-DOPENAL_INCLUDE_DIR=$ARM64_AL_PATH/include/AL \
-DCMAKE_OSX_ARCHITECTURES=arm64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=$ARM64_PREFIX_PATH \
-DCMAKE_INSTALL_PREFIX=$ARM64_PREFIX_PATH \
../
ninja
mkdir -p "${EXECUTABLE_FOLDER_PATH}"
cp openmohaa.arm64 "${EXECUTABLE_FOLDER_PATH}"/"${EXECUTABLE_NAME}"
cp omohaaded.arm64 "${EXECUTABLE_FOLDER_PATH}"/omohaaded
cp code/client/cgame/cgame.arm64.dylib "${EXECUTABLE_FOLDER_PATH}"
cp code/server/fgame/game.arm64.dylib "${EXECUTABLE_FOLDER_PATH}"
cd ..

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"
    
    cd ${BUILT_PRODUCTS_DIR}
    install_name_tool -add_rpath @executable_path/. ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    cp /usr/local/lib/libopenal.1.dylib ${EXECUTABLE_FOLDER_PATH}/
    cd ..
else
    echo lipo /usr/local/opt/openal-soft/lib/libopenal.1.dylib /opt/Homebrew/opt/openal-soft/lib/libopenal.1.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libopenal.1.dylib" -create
    lipo /usr/local/opt/openal-soft/lib/libopenal.1.dylib /opt/Homebrew/opt/openal-soft/lib/libopenal.1.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libopenal.1.dylib" -create

    "../MSPBuildSystem/common/build_app_bundle.sh"
fi

cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/*.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/*.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"