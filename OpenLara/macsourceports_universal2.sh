# game/app specific values
# OpenLara has no version numbers (its tags are just dates, the last from 2019):
# dated builds are just the date (20261116, see constants.sh); a build without
# one is still called 1.0
if [ -n "${MSP_VERSION_DATE}" ]; then
	export APP_VERSION=""
else
	export APP_VERSION="1.0"
fi
export PRODUCT_NAME="OpenLara"
export PROJECT_NAME="OpenLara"
export PORT_NAME="OpenLara"
export ICONSFILENAME="OpenLara"
export EXECUTABLE_NAME="OpenLara"

# constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="12.0"

CROSS_FILE_DIR=$PWD

cd ../../${PROJECT_NAME}

# Built from XProger/OpenLara. Upstream looks for game data next to the .app;
# we keep it in ~/Library/Application Support/OpenLara/tr1/ (used to be our fork).
# Skip if it's already applied.
if ! git apply -R --check "${CROSS_FILE_DIR}/msp-appsupport.patch" 2>/dev/null; then
	git apply "${CROSS_FILE_DIR}/msp-appsupport.patch" || exit 1
fi

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
	MACOSX_DEPLOYMENT_TARGET="12.0" \
	SYMROOT=$PWD/${BUILT_PRODUCTS_DIR}

echo $PWD
echo mv ${BUILT_PRODUCTS_DIR}/Release/OpenLara.app "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
mv ${BUILT_PRODUCTS_DIR}/Release/OpenLara.app "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"

"../MSPBuildSystem/common/copy_dependencies.sh" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"