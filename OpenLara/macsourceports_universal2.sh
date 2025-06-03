# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="OpenLara"
export PROJECT_NAME="OpenLara"
export PORT_NAME="OpenLara"
export ICONSFILENAME="OpenLara"
export EXECUTABLE_NAME="OpenLara"

# constants
source ../common/constants.sh
cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

# xcodebuild will make the release folder for us
xcodebuild \
	-project src/platform/osx/OpenLara.xcodeproj \
	-scheme "OpenLara" \
	-configuration Release \
	-arch x86_64 -arch arm64 \
	clean \
	build \
	-verbose \
	INFOPLIST_FILE=OpenLara-Info.plist \
	CLANG_WARN_IMPLICIT_FUNCTION_DECLARATIONS=NO \
	GCC_TREAT_WARNINGS_AS_ERRORS=NO \
	CLANG_TREAT_WARNINGS_AS_ERRORS=NO \
	CODE_SIGNING_ALLOWED="NO" \
	WRAPPER_NAME=OpenLara.app \
	EXECUTABLE_NAME=OpenLara \
	ONLY_ACTIVE_ARCH="NO" \
	MACOSX_DEPLOYMENT_TARGET="10.13" \
	SYMROOT=$PWD/${BUILT_PRODUCTS_DIR}

echo $PWD
echo mv ${BUILT_PRODUCTS_DIR}/Release/OpenLara.app "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
mv ${BUILT_PRODUCTS_DIR}/Release/OpenLara.app "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"

"../MSPBuildSystem/common/copy_dependencies.sh" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"