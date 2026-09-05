# game/app specific values
export APP_VERSION="7.1.0"
export PRODUCT_NAME="crispy-doom"
export PROJECT_NAME="crispy-doom"
export PORT_NAME="crispy-doom"
export ICONSFILENAME="crispy-doom"
export EXECUTABLE_NAME="launcher"
export PKGINFO="APPLBGDM"
export GIT_DEFAULT_BRANCH="main"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.15"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	# turns crispy-doom-7.1.0 into 7.1.0
	export APP_VERSION="${2/crispy-doom-/}"
	export GIT_TAG="$2"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"
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

# cp source/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
# "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

cd ../pkg/osx
make clean
make launcher

cd ../..
cp ${BUILT_PRODUCTS_DIR}/src/crispy-doom ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${BUILT_PRODUCTS_DIR}/src/crispy-setup ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/crispy-doom-setup
cp ${BUILT_PRODUCTS_DIR}/src/crispy-heretic ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${BUILT_PRODUCTS_DIR}/src/crispy-setup ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/crispy-heretic-setup
cp ${BUILT_PRODUCTS_DIR}/src/crispy-hexen ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${BUILT_PRODUCTS_DIR}/src/crispy-setup ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/crispy-hexen-setup
cp ${BUILT_PRODUCTS_DIR}/src/crispy-strife ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${BUILT_PRODUCTS_DIR}/src/crispy-setup ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/crispy-strife-setup
cp ${BUILT_PRODUCTS_DIR}/src/crispy-setup ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${BUILT_PRODUCTS_DIR}/src/crispy-server ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp pkg/osx/launcher ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp -R pkg/osx/Resources/launcher.nib ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/crispy-doom ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/crispy-doom-setup ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/crispy-heretic ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/crispy-heretic-setup ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/crispy-hexen ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/crispy-hexen-setup ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/crispy-strife ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/crispy-strife-setup ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/crispy-setup ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/crispy-server ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/launcher ${FRAMEWORKS_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"