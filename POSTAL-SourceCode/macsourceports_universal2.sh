# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="postal"
export PROJECT_NAME="POSTAL-SourceCode"
export PORT_NAME="postal"
export ICONSFILENAME="postal"
export EXECUTABLE_NAME="postal1"
export PKGINFO="APPLPSTL"

# constants
source ../common/constants.sh
source ../common/signing_values.local
export MINIMUM_SYSTEM_VERSION="10.7"

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

# create folders for make
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

# perform builds with make
make clean
(make macosx_x86_64=1 -j$NCPU)
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mv bin/${EXECUTABLE_NAME}-x86_64 ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}

make clean
(make macosx_arm64=1 -j$NCPU)
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mv bin/${EXECUTABLE_NAME}-arm64 ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}

"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"

cd ${BUILT_PRODUCTS_DIR}
install_name_tool -add_rpath @executable_path/../Frameworks/. "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
"../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${FRAMEWORKS_FOLDER_PATH}"
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"