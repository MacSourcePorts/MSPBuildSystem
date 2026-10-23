# game/app specific values
export APP_VERSION="0.13.2"
export PRODUCT_NAME="openQ4"
export PROJECT_NAME="openQ4"
export PORT_NAME="openQ4"
export ICONSFILENAME="quake4"
export EXECUTABLE_NAME="openQ4"
export PKGINFO="APPLOPQ4"

# constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

source ../MSPBuildSystem/common/signing_values.local

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}
rm -rf ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}

# TODO: is this necessary when Buildbot clones it?
chmod +x tools/build/meson_setup.sh
chmod +x tools/build/prepare_macos_moltenvk.sh
rm -rf ".install"

mkdir ${X86_64_BUILD_FOLDER}

PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" \
bash tools/build/meson_setup.sh setup --wipe ${X86_64_BUILD_FOLDER} \
--backend ninja \
--buildtype=debugoptimized -Db_ndebug=true \
--wrap-mode=forcefallback \
--cross-file="../MSPBuildSystem/libraries/cross-x86_64.txt" \
-Dplatform_backend=sdl3 \
-Dmacos_graphics_bridge="metal" \
-Dmacos_openal_provider=system \
-Dversion_track=stable \
-Dversion_base_override="$APP_VERSION" \
-Dpkg_config_path="/usr/local/lib/pkgconfig"
./tools/build/meson_setup.sh compile -C "${X86_64_BUILD_FOLDER}"
./tools/build/meson_setup.sh install -C "${X86_64_BUILD_FOLDER}" --no-rebuild --skip-subprojects

mv .install "${X86_64_BUILD_FOLDER}"
rm -rf ".install/"

mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}
mkdir -p ${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}

cp "${X86_64_BUILD_FOLDER}/.install/${EXECUTABLE_NAME}-client_x64" ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
cp "${X86_64_BUILD_FOLDER}/.install/renderer-vk_x64.dylib" ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}

mkdir ${ARM64_BUILD_FOLDER}

PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" \
bash tools/build/meson_setup.sh setup --wipe ${ARM64_BUILD_FOLDER} \
--backend ninja \
--buildtype=debugoptimized -Db_ndebug=true \
--wrap-mode=forcefallback \
--cross-file="../MSPBuildSystem/libraries/cross-arm64.txt" \
-Dplatform_backend=sdl3 \
-Dmacos_graphics_bridge="metal" \
-Dmacos_openal_provider=system \
-Dversion_track=stable \
-Dversion_base_override="$APP_VERSION" \
-Dpkg_config_path="/usr/local/lib/pkgconfig"
./tools/build/meson_setup.sh compile -C "${ARM64_BUILD_FOLDER}"
./tools/build/meson_setup.sh install -C "${ARM64_BUILD_FOLDER}" --no-rebuild --skip-subprojects

mv .install "${ARM64_BUILD_FOLDER}"
rm -rf ".install"

mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}
mkdir -p ${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}

cp "${ARM64_BUILD_FOLDER}/.install/${EXECUTABLE_NAME}-client_arm64" ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
cp "${ARM64_BUILD_FOLDER}/.install/renderer-vk_arm64.dylib" ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}

mkdir ${BUILT_PRODUCTS_DIR}

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"
mkdir -p ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}

"../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
cp "${X86_64_BUILD_FOLDER}/renderer-vk_x64.dylib" ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
cp "${ARM64_BUILD_FOLDER}/renderer-vk_arm64.dylib" ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
cp /usr/local/lib/libMoltenVK.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}

cp -a "${ARM64_BUILD_FOLDER}/.install/assets" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/assets
mkdir -p ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/baseoq4
cp -a ${X86_64_BUILD_FOLDER}/.install/baseoq4/*.pk4 ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/baseoq4
cp -a ${X86_64_BUILD_FOLDER}/.install/baseoq4/*.json ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/baseoq4
cp -a ${X86_64_BUILD_FOLDER}/.install/baseoq4/*.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
cp -a ${ARM64_BUILD_FOLDER}/.install/baseoq4/*.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
cp -a "${ARM64_BUILD_FOLDER}/.install/licenses" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/licenses

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/*.dylib

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"