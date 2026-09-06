# game/app specific values
export APP_VERSION="3.0.10"
export PRODUCT_NAME="Perimeter"
export PROJECT_NAME="Perimeter"
export PORT_NAME="Perimeter"
export ICONSFILENAME="Perimeter"
export EXECUTABLE_NAME="Perimeter"
export EXECUTABLE_SUFFIX=".sh"
export PKGINFO="APPLPERI"

export RANLIB=/usr/bin/ranlib
export AR=/usr/bin/ar

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

export MACOSX_DEPLOYMENT_TARGET=10.15

source ~/VulkanSDK/1.4.313.0/setup-env.sh
export PKG_CONFIG_PATH="$VULKAN_SDK/lib/pkgconfig/"
export DYLD_LIBRARY_PATH="$VULKAN_SDK/lib/:$DYLD_LIBRARY_PATH"

cd ${X86_64_BUILD_FOLDER}

cmake -G Ninja \
-DCMAKE_OSX_ARCHITECTURES=x86_64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
../
ninja -j$NCPU
mv Source/${WRAPPER_NAME} .
mkdir -p ${WRAPPER_NAME}/Contents/Frameworks
cp Source/Render/dxvk-prefix/src/dxvk-build/src/d3d9/libdxvk_d3d9.dylib ${WRAPPER_NAME}/Contents/Frameworks

cd ../${ARM64_BUILD_FOLDER}

cmake -G Ninja \
-DCMAKE_OSX_ARCHITECTURES=arm64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
../
ninja -j$NCPU
mv Source/${WRAPPER_NAME} .
mkdir -p ${WRAPPER_NAME}/Contents/Frameworks
cp Source/Render/dxvk-prefix/src/dxvk-build/src/d3d9/libdxvk_d3d9.dylib ${WRAPPER_NAME}/Contents/Frameworks

cd ..

export EXTRA_INFO_PLIST_ENTRIES="
    <key>LSMinimumSystemVersionByArchitecture</key>
    <dict>
        <key>x86_64</key>
        <string>10.15</string>
        <key>arm64</key>
        <string>11.0</string>
    </dict>"

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"
mkdir -p "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libdxvk_d3d9.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libdxvk_d3d9.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libdxvk_d3d9.dylib" -create
cp $VULKAN_SDK/lib/libvulkan.1.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
cp $VULKAN_SDK/lib/libMoltenVK.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/vulkan/icd.d"
cp "../MSPBuildSystem/Perimeter/MoltenVK_icd.json" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/vulkan/icd.d"
cp "../MSPBuildSystem/Perimeter/Perimeter.sh" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/Perimeter ${FRAMEWORKS_FOLDER_PATH}
cd ..

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"