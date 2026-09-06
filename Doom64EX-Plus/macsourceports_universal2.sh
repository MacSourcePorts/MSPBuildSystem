# game/app specific values
export APP_VERSION="4.1.0.0"
export PRODUCT_NAME="DOOM64EXPlus"
export PROJECT_NAME="Doom64EX-Plus"
export PORT_NAME="DOOM64EXPlus"
export ICONSFILENAME="DOOM64EXPlus"
export EXECUTABLE_NAME="DOOM64EXPlus"

# constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.13"

cd ../../${PROJECT_NAME}

cp ../MSPBuildSystem/${PROJECT_NAME}/Libs/* Xcode

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at: $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}

# xcodebuild will make the release folder for us
xcodebuild \
	-project XCode/DOOM64EXPlus.xcodeproj \
	-scheme "doom64explus" \
	-configuration Release \
	-arch x86_64 -arch arm64 \
	clean \
	build \
	-verbose \
	INFOPLIST_FILE=DOOM64EX--Info.plist \
	CLANG_WARN_IMPLICIT_FUNCTION_DECLARATIONS=NO \
	GCC_TREAT_WARNINGS_AS_ERRORS=NO \
	CLANG_TREAT_WARNINGS_AS_ERRORS=NO \
	CODE_SIGNING_ALLOWED="NO" \
	WRAPPER_NAME=DOOM64EXPlus.app \
	EXECUTABLE_NAME=DOOM64EXPlus \
	ONLY_ACTIVE_ARCH="NO" \
	SYMROOT=$PWD/${BUILT_PRODUCTS_DIR}

echo $PWD
echo mv ${BUILT_PRODUCTS_DIR}/Release/DOOM64EXPlus.app "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
mv ${BUILT_PRODUCTS_DIR}/Release/DOOM64EXPlus.app "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"

"../MSPBuildSystem/common/copy_dependencies.sh" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"