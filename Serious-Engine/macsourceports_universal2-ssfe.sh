# game/app specific values
export APP_VERSION="ssfe-1.1"
export PRODUCT_NAME="ssam-tfe"
export PROJECT_NAME="Serious-Engine"
export PORT_NAME="Serious Engine"
export ICONSFILENAME="ssfe"
export EXECUTABLE_NAME="ssam-tfe"
export PKGINFO="APPLSSFE"
export GIT_TAG="1.5.2"
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

    # check out the latest release tag
    # NOTE: skipping for now until I do a PR to search in the app bundle for the game files.
    # echo git checkout tags/${GIT_TAG}
    # git checkout tags/${GIT_TAG}
fi

rm -rf ${BUILT_PRODUCTS_DIR}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    mkdir ${BUILT_PRODUCTS_DIR}
    cd ${BUILT_PRODUCTS_DIR}
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_CXX_FLAGS="-Wno-error=enum-constexpr-conversion" \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_CXX_STANDARD_REQUIRED=ON \
    -DCMAKE_PREFIX_PATH=/usr/local \
    -DTFE=TRUE \
    ../Sources
    mkdir -p ${EXECUTABLE_FOLDER_PATH}
    mkdir -p ${FRAMEWORKS_FOLDER_PATH}
    mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}
    cmake --build . --parallel $NCPU
    cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
    cp Debug/* ${UNLOCALIZED_RESOURCES_FOLDER_PATH}
    "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
else
    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}
    cd ${ARM64_BUILD_FOLDER}
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_OSX_ARCHITECTURES=arm64 ../Sources -DCMAKE_CXX_FLAGS="-Wno-error=enum-constexpr-conversion" -DCMAKE_CXX_STANDARD=17 -DCMAKE_CXX_STANDARD_REQUIRED=ON -DTFE=TRUE
    mkdir -p ${EXECUTABLE_FOLDER_PATH}
    mkdir -p ${FRAMEWORKS_FOLDER_PATH}

    cd ..
    rm -rf ${X86_64_BUILD_FOLDER}
    mkdir ${X86_64_BUILD_FOLDER}
    cd ${X86_64_BUILD_FOLDER}
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_OSX_ARCHITECTURES=x86_64 ../Sources -DCMAKE_CXX_FLAGS="-Wno-error=enum-constexpr-conversion" -DCMAKE_CXX_STANDARD=17 -DCMAKE_CXX_STANDARD_REQUIRED=ON -DTFE=TRUE -DCMAKE_PREFIX_PATH=/usr/local
    mkdir -p ${EXECUTABLE_FOLDER_PATH}
    mkdir -p ${FRAMEWORKS_FOLDER_PATH}

    cd ..
    cd ${ARM64_BUILD_FOLDER}
    make -j$NCPU
    cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
    cp Debug/* ${FRAMEWORKS_FOLDER_PATH}

    cd ..
    cd ${X86_64_BUILD_FOLDER}
    make -j$NCPU
    cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
    cp Debug/* ${FRAMEWORKS_FOLDER_PATH}
fi 

cd ..

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

    cp /usr/local/lib/libvorbis.0.4.9.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbis.dylib"
    cp /usr/local/lib/libvorbisfile.3.3.8.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisfile.dylib"
    cp /usr/local/lib/libogg.0.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libogg.dylib"
    cp /usr/local/lib/libvorbisenc.2.0.12.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisenc.dylib"
    install_name_tool -change @rpath/libvorbis.0.4.9.dylib @rpath/libvorbis.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisfile.dylib
    install_name_tool -change @rpath/libvorbis.0.4.9.dylib @rpath/libvorbis.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisenc.dylib
    install_name_tool -change @rpath/libogg.0.dylib @rpath/libogg.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisfile.dylib
    install_name_tool -change @rpath/libogg.0.dylib @rpath/libogg.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbis.dylib
    install_name_tool -change @rpath/libogg.0.dylib @rpath/libogg.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisenc.dylib
else
    "../MSPBuildSystem/common/build_app_bundle.sh"

    # lipo any app-specific libraries
    lipo ${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libEntities.dylib ${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libEntities.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libEntities.dylib" -create
    lipo ${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libGame.dylib ${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libGame.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libGame.dylib" -create
    lipo ${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libShaders.dylib ${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libShaders.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libShaders.dylib" -create

    # lipo any app-specific libraries
    # we're doing things the hard way here because these aren't linked in but they need to be in the same dir
    lipo /usr/local/lib/libvorbis.dylib /opt/homebrew/lib/libvorbis.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbis.dylib" -create
    lipo /usr/local/lib/libvorbisfile.dylib /opt/homebrew/lib/libvorbisfile.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisfile.dylib" -create
    install_name_tool -change /opt/homebrew/Cellar/libvorbis/1.3.7/lib/libvorbis.0.dylib @executable_path/../Resources/libvorbis.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisfile.dylib
    install_name_tool -change /usr/local/Cellar/libvorbis/1.3.7/lib/libvorbis.0.dylib @executable_path/../Resources/libvorbis.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisfile.dylib
    lipo /usr/local/lib/libogg.dylib /opt/homebrew/lib/libogg.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libogg.dylib" -create
    lipo /usr/local/lib/libvorbisenc.dylib /opt/homebrew/lib/libvorbisenc.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisenc.dylib" -create
fi

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbis.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisfile.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libogg.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libvorbisenc.dylib

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libEntities.dylib"
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libGame.dylib"
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libShaders.dylib"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"