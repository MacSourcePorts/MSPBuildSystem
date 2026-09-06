# game/app specific values
export APP_VERSION="1.5.3"
export PRODUCT_NAME="devilutionX"
export PROJECT_NAME="devilutionX"
export PORT_NAME="DevilutionX"
export ICONSFILENAME="devilutionX"
export EXECUTABLE_NAME="devilutionX"
export PKGINFO="APPLEDVLX"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.12"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
cmake  \
-DBUILD_TESTING=OFF  \
-DCMAKE_OSX_ARCHITECTURES="x86_64" \
-DCMAKE_BUILD_TYPE=Release  \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7  \
..  \
-Wno-dev

cmake --build . --parallel $NCPU

cd ..

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake  \
-DBUILD_TESTING=OFF  \
-DCMAKE_OSX_ARCHITECTURES="arm64" \
-DCMAKE_BUILD_TYPE=Release  \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7  \
..  \
-Wno-dev

cmake --build . --parallel $NCPU

cd ..

export EXTRA_INFO_PLIST_ENTRIES="
    <key>CFBundleDisplayName</key>
	<string>DevilutionX</string>
    <key>SDL_FILESYSTEM_BASE_DIR_TYPE</key>
	<string>parent</string>"

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"