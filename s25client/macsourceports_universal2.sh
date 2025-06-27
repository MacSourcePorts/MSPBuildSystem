# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="s25client"
export PROJECT_NAME="s25client"
export PORT_NAME="s25client"
export ICONSFILENAME="s25client"
export EXECUTABLE_NAME="s25client"
export PKGINFO="APPLRTTR"
export GIT_DEFAULT_BRANCH="master"
export ENTITLEMENTS_FILE="../MSPBuildSystem/Serious-Engine/Serious-Engine.entitlements"

#constants
source ../common/constants.sh
source ../common/signing_values.local

cd ../../${PROJECT_NAME}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	echo "Skipping git because we're on the build server"
else
    # reset to the main branch
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}

    # fetch the latest 
    echo git pull
    git pull
fi

rm -rf ${BUILT_PRODUCTS_DIR}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
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
else
    # create makefiles with cmake, perform builds with make
    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}
    mkdir -p ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}
    cd ${ARM64_BUILD_FOLDER}
    cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DLUA_INCLUDE_DIR=/opt/homebrew/include/lua-5.1 \
    -DLUA_LIBRARY=/opt/homebrew/lib/liblua.5.1.dylib \
    -DRTTR_BUNDLE=ON \
    -DRTTR_GAMEDIR="~/Library/Application Support/Return To The Roots" \
    ..
    make -j$NCPU
    cp -a Contents/* ${CONTENTS_FOLDER_PATH}
    cp -a Info.plist ${CONTENTS_FOLDER_PATH}
    cp ../extras/macosLauncher/rttr.terminal ${EXECUTABLE_FOLDER_PATH}
    dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/driver/audio/libaudioSDL.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
    dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/driver/video/libvideoSDL2.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/

    cd ..
    rm -rf ${X86_64_BUILD_FOLDER}
    mkdir ${X86_64_BUILD_FOLDER}
    mkdir -p ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}
    cd ${X86_64_BUILD_FOLDER}
    cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCMAKE_PREFIX_PATH=/usr/local \
    -DLUA_INCLUDE_DIR=/usr/local/include/lua-5.1 \
    -DLUA_LIBRARY=/usr/local/lib/liblua.5.1.dylib \
    -DRTTR_BUNDLE=ON \
    -DRTTR_GAMEDIR="~/Library/Application Support/Return To The Roots" \
    ..
    make -j$NCPU
    cp -a Contents/* ${CONTENTS_FOLDER_PATH}
    cp -a Info.plist ${CONTENTS_FOLDER_PATH}
    cp ../extras/macosLauncher/rttr.terminal ${EXECUTABLE_FOLDER_PATH}
    dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/driver/audio/libaudioSDL.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
    dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/driver/video/libvideoSDL2.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
fi

cd ..

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"
else
    "../MSPBuildSystem/common/build_app_bundle.sh"

    # lipo any app-specific libraries
    mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/driver/audio
    lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/driver/audio/libaudioSDL.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/driver/audio/libaudioSDL.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/driver/audio/libaudioSDL.dylib" -create
    mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/driver/video
    lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/driver/video/libvideoSDL2.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/driver/video/libvideoSDL2.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/driver/video/libvideoSDL2.dylib" -create
    lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/s25edit ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/s25edit -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/s25edit" -create
    lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/s25update ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/s25update -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/s25update" -create
    lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/starter ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/starter -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/starter" -create

    mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/share
    cp -a ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/share/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/share

    cp -a ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}
    cp -a ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}

    codesign --force --timestamp --options runtime  --entitlements "${ENTITLEMENTS_FILE}" --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/driver/audio/libaudioSDL.dylib
    codesign --force --timestamp --options runtime  --entitlements "${ENTITLEMENTS_FILE}" --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/driver/video/libvideoSDL2.dylib
    codesign --force --timestamp --options runtime  --entitlements "${ENTITLEMENTS_FILE}" --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/s25update
    codesign --force --timestamp --options runtime  --entitlements "${ENTITLEMENTS_FILE}" --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/starter
    codesign --force --timestamp --options runtime  --entitlements "${ENTITLEMENTS_FILE}" --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/s25edit
    codesign --force --timestamp --options runtime  --entitlements "${ENTITLEMENTS_FILE}" --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/s25client
fi

# copy over any resources
cp extras/macosLauncher/rttr.terminal ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}

# for some reason this one directory breaks app signing. I don't know what removing it causes but it's got to go. If it causes problems later we can reinvestigate
rm -rf ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/share/s25rttr/RTTR/assets/nations/Babylonians/jobs.bob

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"