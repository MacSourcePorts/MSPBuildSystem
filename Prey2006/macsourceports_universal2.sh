# game/app specific values
export APP_VERSION="1.5.4"
export PRODUCT_NAME="Prey2006"
export PROJECT_NAME="Prey2006"
export PORT_NAME="Prey2006"
export ICONSFILENAME="prey2006"
export EXECUTABLE_NAME="prey06"
export PKGINFO="APPLPREY"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

# For whatever reason,
# a) Specifying "-arch x86_64 does both x86_64/Intel and arm64"
# b) The Intel version works fine with gamearm64.dylib
rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
cmake -G "Unix Makefiles" -DCMAKE_DISABLE_PRECOMPILE_HEADERS=ON -DCMAKE_C_FLAGS_RELEASE="-arch x86_64 -w" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2=ON -DOPENAL_LIBRARY=/usr/local/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/usr/local/include ../neo
cmake --build . --parallel $NCPU

cd ..

mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base" || exit 1;
cp output/macosx/prey06 "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp output/macosx/prey06ded "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp output/macosx/prey06ded "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp ${BUILT_PRODUCTS_DIR}/gamearm64.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp output/macosx/base/pak007.pk4 "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base"

"../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

#create any app-specific directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base" || exit 1;
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"