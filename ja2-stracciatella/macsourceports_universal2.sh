# game/app specific values
export APP_VERSION="0.22.1"
export PRODUCT_NAME="ja2-stracciatella"
export PROJECT_NAME="ja2-stracciatella"
export PORT_NAME="JA2 Stracciatella"
export ICONSFILENAME="ja2-stracciatella"
export EXECUTABLE_NAME="ja2-launcher"
export PKGINFO="APPLJA2"
export GIT_DEFAULT_BRANCH="master"
export ENTITLEMENTS_FILE="../MSPBuildSystem/ja2-stracciatella/ja2-stracciatella.entitlements"
export GIT_TAG="v0.22.1"

#constants
source ../common/constants.sh
source ../common/signing_values.local

export HIGH_RESOLUTION_CAPABLE="true"
export PATH="~/.cargo/bin:$PATH"
export MINIMUM_SYSTEM_VERSION="10.13"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	export GIT_TAG="$2"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"
fi

# Fix issue with static Homebrew linking
gsed -i 's|/opt/homebrew/opt/fltk@1.3/lib/libfltk_forms.a /opt/homebrew/opt/fltk@1.3/lib/libfltk_images.a /opt/homebrew/opt/fltk@1.3/lib/libfltk.a|/usr/local/lib/libfltk_forms.dylib /usr/local/lib/libfltk_images.dylib /usr/local/lib/libfltk.dylib|g' src/launcher/CMakeLists.txt

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}
mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
mkdir -p ${EXECUTABLE_FOLDER_PATH}
mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchain-macos.cmake \
    -DCPACK_GENERATOR=Bundle \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13 \
    -DWITH_UNITTESTS=OFF \
    -DLOCAL_LUA_LIB=OFF \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCARGO_BUILD_TARGET=x86_64-apple-darwin \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ..
cmake --build . --parallel $NCPU
cp ja2 "${EXECUTABLE_FOLDER_PATH}"
cp ja2-launcher "${EXECUTABLE_FOLDER_PATH}"

cd ..

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
mkdir -p ${EXECUTABLE_FOLDER_PATH}
mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchain-macos.cmake \
    -DCPACK_GENERATOR=Bundle \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13 \
    -DWITH_UNITTESTS=OFF \
    -DLOCAL_LUA_LIB=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ..
cmake --build . --parallel $NCPU
cp ja2 "${EXECUTABLE_FOLDER_PATH}"
cp ja2-launcher "${EXECUTABLE_FOLDER_PATH}"

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"

lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ja2 ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ja2 -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2" -create

install_name_tool -change @rpath/SDL2.framework/Versions/A/SDL2 @rpath/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2"
install_name_tool -change @rpath/SDL2.framework/Versions/A/SDL2 @rpath/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2-launcher"

"../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2
"../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2-launcher

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/ja2 ${FRAMEWORKS_FOLDER_PATH}
cd ..

cp assets/distr-files-mac/README.txt "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/"

cp changes.md "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"

mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/externalized"
cp -a ${ARM64_BUILD_FOLDER}/externalized/* "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/externalized"

mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/mods"
cp -a ${ARM64_BUILD_FOLDER}/mods/* "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/mods"

mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/unittests"
cp -a ${ARM64_BUILD_FOLDER}/unittests/* "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/unittests"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"