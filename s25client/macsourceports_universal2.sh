# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="s25client"
export PROJECT_NAME="s25client"
export PORT_NAME="s25client"
export ICONSFILENAME="s25client"
export EXECUTABLE_NAME="s25client"
export PKGINFO="APPLRTTR"
export ENTITLEMENTS_FILE="../MSPBuildSystem/Serious-Engine/Serious-Engine.entitlements"

#constants
source ../common/constants.sh
source ../common/signing_values.local
export MINIMUM_SYSTEM_VERSION="10.9"

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
-DLUA_INCLUDE_DIR=/usr/local/include/lua \
-DLUA_LIBRARY=/usr/local/lib/liblua.dylib \
-DRTTR_BUNDLE=ON \
-DRTTR_GAMEDIR="~/Library/Application Support/Return To The Roots" \
..
make -j$NCPU
cp -a Contents/* ${CONTENTS_FOLDER_PATH}
cp -a Info.plist ${CONTENTS_FOLDER_PATH}
cp ../extras/macosLauncher/rttr.terminal ${EXECUTABLE_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" "./${EXECUTABLE_FOLDER_PATH}/driver/audio/libaudioSDL.dylib" ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" "./${EXECUTABLE_FOLDER_PATH}/driver/video/libvideoSDL2.dylib" ${FRAMEWORKS_FOLDER_PATH}
cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# copy over any resources
cp extras/macosLauncher/rttr.terminal ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}

# for some reason this one directory breaks app signing. I don't know what removing it causes but it's got to go. If it causes problems later we can reinvestigate
rm -rf ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/share/s25rttr/RTTR/assets/nations/Babylonians/jobs.bob

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"