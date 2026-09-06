# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="Heretic2R-UNIX"
export PROJECT_NAME="Heretic2R-UNIX"
export PORT_NAME="Heretic2R-UNIX"
export ICONSFILENAME="heretic2r"
export EXECUTABLE_NAME="heretic2r"
export PKGINFO="APPLH2R"

# constants
source ../common/constants.sh

ARM64_CFLAGS="-mmacosx-version-min=10.14"
ARM64_LDFLAGS="-mmacosx-version-min=10.14 -headerpad_max_install_names"
x86_64_CFLAGS="-mmacosx-version-min=10.14"
x86_64_LDFLAGS="-mmacosx-version-min=10.14 -headerpad_max_install_names"

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}
rm -rf ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}

(ARCH=x86_64 make clean) || exit 1;
(ARCH=x86_64 CFLAGS=$x86_64_CFLAGS LDFLAGS=$x86_64_LDFLAGS make -j$NCPU) || exit 1;
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mv build/release/* ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
rm -rd build/release

(ARCH=arm64 make clean) || exit 1;
(ARCH=arm64 CFLAGS=$ARM64_CFLAGS LDFLAGS=$ARM64_LDFLAGS make -j$NCPU) || exit 1;
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mv build/release/* ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
rm -rd build/release

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"

#create any app-specific directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base" || exit 1;
fi

#lipo any app-specific things
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/gamex86.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/gamex86.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base/gamex86.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/Player.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/Player.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base/Player.dylib" -create
lipo "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/Client Effects.dylib" "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/Client Effects.dylib" -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base/Client Effects.dylib" -create

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" ${FRAMEWORKS_FOLDER_PATH}
cd ..

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"