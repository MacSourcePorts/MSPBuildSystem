# game/app specific values
export APP_VERSION="0.7"
export PRODUCT_NAME="openmohaa"
export PROJECT_NAME="openmohaa"
export PORT_NAME="openmohaa"
export ICONSFILENAME="openmohaa"
export EXECUTABLE_NAME="openmohaa"
export PKGINFO="APPLMOHA"
export GIT_TAG="0.7"
export GIT_DEFAULT_BRANCH="main"
export MINIMUM_SYSTEM_VERSION="10.15"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	export GIT_TAG="$2"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"
fi

export PATH=$PATH:~/Library/Python/3.9/bin/

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
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
../
ninja
mkdir -p "${EXECUTABLE_FOLDER_PATH}"
cp openmohaa "${EXECUTABLE_FOLDER_PATH}"/"${EXECUTABLE_NAME}"
cp omohaaded "${EXECUTABLE_FOLDER_PATH}"/omohaaded
cp code/client/cgame/cgame.dylib "${EXECUTABLE_FOLDER_PATH}"
cp code/server/fgame/game.dylib "${EXECUTABLE_FOLDER_PATH}"

cd ../${ARM64_BUILD_FOLDER}

cmake -G Ninja \
-DOPENAL_INCLUDE_DIR=$ARM64_AL_PATH/include/AL \
-DCMAKE_OSX_ARCHITECTURES=arm64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
../
ninja
mkdir -p "${EXECUTABLE_FOLDER_PATH}"
cp openmohaa "${EXECUTABLE_FOLDER_PATH}"/"${EXECUTABLE_NAME}"
cp omohaaded "${EXECUTABLE_FOLDER_PATH}"/omohaaded
cp code/client/cgame/cgame.dylib "${EXECUTABLE_FOLDER_PATH}"
cp code/server/fgame/game.dylib "${EXECUTABLE_FOLDER_PATH}"
cd ..

"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cp /usr/local/lib/libopenal.1.dylib ${FRAMEWORKS_FOLDER_PATH}/
cd ..

cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/*.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/*.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"