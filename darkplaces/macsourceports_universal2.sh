# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="darkplaces"
export PROJECT_NAME="darkplaces"
export PORT_NAME="darkplaces"
export ICONSFILENAME="darkplaces"
export EXECUTABLE_NAME="darkplaces-sdl"
export PKGINFO="APPLDARK"
export GIT_TAG="1.0"
export GIT_DEFAULT_BRANCH="master"
export ENTITLEMENTS_FILE="../MSPBuildSystem/darkplaces/darkplaces.entitlements"

# constants
source ../common/constants.sh
source ../common/signing_values.local
export MINIMUM_SYSTEM_VERSION="10.7"
export STRIP=/usr/bin/strip

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

# create folders for make
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

# perform builds with make
make clean
(SDL_CONFIG="/usr/local/bin/sdl2-config" CC="clang -arch x86_64 -mmacosx-version-min=10.7" make sdl-release -j$NCPU)
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mv ${EXECUTABLE_NAME} ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}

make clean
(SDL_CONFIG="usr/local/bin/sdl2-config" CC="clang -arch arm64 -mmacosx-version-min=10.7" make sdl-release -j$NCPU)
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mv ${EXECUTABLE_NAME} ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"

cd ${BUILT_PRODUCTS_DIR}
install_name_tool -add_rpath @executable_path/../Frameworks/. "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
"../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${FRAMEWORKS_FOLDER_PATH}"
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

# create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"