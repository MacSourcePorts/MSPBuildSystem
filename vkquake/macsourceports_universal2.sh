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

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	export GIT_TAG="$2"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"
fi

rm -rf ${BUILT_PRODUCTS_DIR}
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

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

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"