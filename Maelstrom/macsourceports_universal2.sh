# game/app specific values
export APP_VERSION="3.07"
export PRODUCT_NAME="Maelstrom"
export PROJECT_NAME="Maelstrom"
export PORT_NAME="Maelstrom 3.0"
export ICONSFILENAME="Maelstrom"
export EXECUTABLE_NAME="Maelstrom"
export PKGINFO="APPLMLST"
export GIT_TAG="1.4.0"
export GIT_DEFAULT_BRANCH="main"

# constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}
# because we maintain the github repo of this port and it's rare 
# that it will ever change we're going to skip the whole part with git

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

# Intel is the same for both local and build server
make clean
(ARCH=x86_64 AM_CPPFLAGS="-mmacosx-version-min=10.7" LDFLAGS="-mmacosx-version-min=10.7" INCLUDES="-I/usr/local/include/SDL2" LIBS="-L/usr/local/lib -lSDL2 -lSDL2_net" make -j$NCPU)
mkdir -p ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
cp "${EXECUTABLE_NAME}" ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"

# Apple Silicon location different for build server
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    make clean
    (ARCH=arm64 AM_CPPFLAGS="-mmacosx-version-min=10.7" LDFLAGS="-mmacosx-version-min=10.7" INCLUDES="-I/usr/local/include/SDL2" LIBS="-L/usr/local/lib -lSDL2 -lSDL2_net" make -j$NCPU)
    mkdir -p ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
    cp "${EXECUTABLE_NAME}" ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"

    # TODO: figure out how if/to factor out lipo step
    mkdir -p ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}"
    lipo "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -create
    install_name_tool -add_rpath @executable_path/. "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
    "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
else
    make clean
    (ARCH=arm64 AM_CPPFLAGS="-mmacosx-version-min=10.7" LDFLAGS="-mmacosx-version-min=10.7" INCLUDES="-I/opt/homebrew/include/SDL2" LIBS="-L/opt/homebrew/lib -lSDL2 -lSDL2_net" make -j$NCPU)
    mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
    cp "${EXECUTABLE_NAME}" ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
fi

mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" || exit 1;
mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Images" || exit 1;
cp -a Images/*.bmp ${BUILT_PRODUCTS_DIR}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Images"
cp -a Images/*.cicn ${BUILT_PRODUCTS_DIR}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Images"
cp "icon.bmp" ${BUILT_PRODUCTS_DIR}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
cp "Maelstrom_Fonts" ${BUILT_PRODUCTS_DIR}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
cp "Maelstrom_Sounds" ${BUILT_PRODUCTS_DIR}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
cp "Maelstrom_Sprites" ${BUILT_PRODUCTS_DIR}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"
else
    "../MSPBuildSystem/common/build_app_bundle.sh"
fi

#sign and notarize (with entitlements)
export ENTITLEMENTS_FILE="Maelstrom.entitlements"
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"