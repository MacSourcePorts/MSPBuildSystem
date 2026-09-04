# game/app specific values
export APP_VERSION="3.0.10"
export PRODUCT_NAME="Perimeter"
export PROJECT_NAME="Perimeter"
export PORT_NAME="Perimeter"
export ICONSFILENAME="Perimeter"
export EXECUTABLE_NAME="Perimeter"
export PKGINFO="APPLPERI"
# export GIT_TAG="0.7"
export GIT_DEFAULT_BRANCH="cmake"

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

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

export MACOSX_DEPLOYMENT_TARGET=10.13

source ~/VulkanSDK/1.4.313.0/setup-env.sh
export PKG_CONFIG_PATH="$VULKAN_SDK/lib/pkgconfig/"
export DYLD_LIBRARY_PATH="$VULKAN_SDK/lib:$DYLD_LIBRARY_PATH"

cd ${X86_64_BUILD_FOLDER}

export LIBRARY_PATH=/usr/local/lib
export LDFLAGS="-arch x86_64 -L/usr/local/lib"

cmake -G Ninja \
-DCMAKE_OSX_ARCHITECTURES=x86_64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
../
ninja -j$NCPU

cd ../${ARM64_BUILD_FOLDER}

cmake -G Ninja \
-DCMAKE_OSX_ARCHITECTURES=arm64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/opt/Homebrew \
-DCMAKE_INSTALL_PREFIX=/opt/Homebrew \
../
ninja -j$NCPU

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

# cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/*.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
# cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/*.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}


#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"