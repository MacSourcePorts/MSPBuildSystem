# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="Akhenaten"
export PROJECT_NAME="Akhenaten"
export PORT_NAME="Akhenaten"
export ICONSFILENAME="akhenaten"
export EXECUTABLE_NAME="akhenaten"

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

gsed -i "s|v1.3.1|v1.3.2|" CMakeLists.txt

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
cmake \
-DCMAKE_OSX_ARCHITECTURES="x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
..
cmake --build . --parallel $NCPU

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
..
cmake --build . --parallel $NCPU

install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/build/build_arm64/lib/libssl.3.dylib  @rpath/libssl.3.dylib "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/build/build_arm64/lib/libcrypto.3.dylib  @rpath/libcrypto.3.dylib "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"