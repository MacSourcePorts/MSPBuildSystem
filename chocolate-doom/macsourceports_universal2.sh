# game/app specific values
export APP_VERSION="3.1.1"
export PRODUCT_NAME="chocolate-doom"
export PROJECT_NAME="chocolate-doom"
export PORT_NAME="chocolate-doom"
export ICONSFILENAME="chocolate-doom"
export EXECUTABLE_NAME="launcher"
export PKGINFO="APPLBGDM"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.15"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	# turns chocolate-doom-3.1.1 into 3.1.1
	export APP_VERSION="${2/chocolate-doom-/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

./autogen.sh

gsed -i "s|CFLAGS = -Wall|CFLAGS = -Wall -arch arm64 -arch x86_64 -mmacosx-version-min=10.7|" pkg/osx/GNUmakefile
gsed -i "s|LDFLAGS = -framework Cocoa|LDFLAGS = -arch arm64 -arch x86_64 -mmacosx-version-min=10.7 -framework Cocoa|" pkg/osx/GNUmakefile

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
mkdir -p ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
..
cmake --build . --parallel $NCPU

cd ../pkg/osx
make clean
make launcher

cd ../..
cp ${BUILT_PRODUCTS_DIR}/src/chocolate-doom ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${BUILT_PRODUCTS_DIR}/src/chocolate-setup ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/chocolate-doom-setup
cp ${BUILT_PRODUCTS_DIR}/src/chocolate-heretic ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${BUILT_PRODUCTS_DIR}/src/chocolate-setup ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/chocolate-heretic-setup
cp ${BUILT_PRODUCTS_DIR}/src/chocolate-hexen ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${BUILT_PRODUCTS_DIR}/src/chocolate-setup ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/chocolate-hexen-setup
cp ${BUILT_PRODUCTS_DIR}/src/chocolate-strife ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${BUILT_PRODUCTS_DIR}/src/chocolate-setup ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/chocolate-strife-setup
cp ${BUILT_PRODUCTS_DIR}/src/chocolate-setup ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${BUILT_PRODUCTS_DIR}/src/chocolate-server ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp pkg/osx/launcher ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp -R pkg/osx/Resources/launcher.nib ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/chocolate-doom ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/chocolate-doom-setup ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/chocolate-heretic ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/chocolate-heretic-setup ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/chocolate-hexen ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/chocolate-hexen-setup ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/chocolate-strife ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/chocolate-strife-setup ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/chocolate-setup ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/chocolate-server ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/launcher ${FRAMEWORKS_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"