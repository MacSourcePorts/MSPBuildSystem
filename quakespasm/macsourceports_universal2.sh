# game/app specific values
export APP_VERSION="0.96.3"
export PRODUCT_NAME="QuakeSpasm"
export PROJECT_NAME="QuakeSpasm"
export PORT_NAME="QuakeSpasm"
export ICONSFILENAME="QuakeSpasm"
export EXECUTABLE_NAME="QuakeSpasm"
export GIT_TAG="0.96.3"
export GIT_DEFAULT_BRANCH="main"

# constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.13"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	export GIT_TAG="$2"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at: " "$APP_VERSION" / "$GIT_TAG"
fi

rm -rf ${BUILT_PRODUCTS_DIR}
rm -rf ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}

# xcodebuild will make the release folder for us
xcodebuild \
	-project MacOSX/QuakeSpasm.xcodeproj \
	-scheme "QuakeSpasm-SDL2-M1" \
	-configuration Release \
	-arch x86_64 -arch arm64 \
	clean \
	build \
	-verbose \
	INFOPLIST_FILE=Info.plist \
	CLANG_WARN_IMPLICIT_FUNCTION_DECLARATIONS=NO \
	GCC_TREAT_WARNINGS_AS_ERRORS=NO \
	CLANG_TREAT_WARNINGS_AS_ERRORS=NO \
	CODE_SIGNING_ALLOWED="NO" \
	WRAPPER_NAME=QuakeSpasm-SDL2-M1.app \
	EXECUTABLE_NAME=QuakeSpasm-SDL2-M1 \
	ONLY_ACTIVE_ARCH="NO" \
	SYMROOT=$PWD/${ARM64_BUILD_FOLDER}

mv ${ARM64_BUILD_FOLDER}/Release/QuakeSpasm-SDL2-M1.app "${ARM64_BUILD_FOLDER}/${WRAPPER_NAME}"
mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/QuakeSpasm-SDL2-M1 ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

# xcodebuild will make the release folder for us
xcodebuild \
	-project MacOSX/QuakeSpasm.xcodeproj \
	-scheme "QuakeSpasm-SDL2-x64" \
	-configuration Release \
	-arch x86_64 -arch arm64 \
	clean \
	build \
	-verbose \
	INFOPLIST_FILE=Info.plist \
	CLANG_WARN_IMPLICIT_FUNCTION_DECLARATIONS=NO \
	GCC_TREAT_WARNINGS_AS_ERRORS=NO \
	CLANG_TREAT_WARNINGS_AS_ERRORS=NO \
	CODE_SIGNING_ALLOWED="NO" \
	WRAPPER_NAME=QuakeSpasm-SDL2-x64.app \
	EXECUTABLE_NAME=QuakeSpasm-SDL2-x64 \
	ONLY_ACTIVE_ARCH="NO" \
	SYMROOT=$PWD/${X86_64_BUILD_FOLDER}

mv ${X86_64_BUILD_FOLDER}/Release/QuakeSpasm-SDL2-x64.app "${X86_64_BUILD_FOLDER}/${WRAPPER_NAME}"
mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/QuakeSpasm-SDL2-x64 ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"

install_name_tool -change @executable_path/libFLAC.dylib @rpath/libFLAC.dylib ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
install_name_tool -change @executable_path/libopus.dylib @rpath/libopus.dylib ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
install_name_tool -change @executable_path/libopusfile.dylib @rpath/libopusfile.dylib ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
install_name_tool -change @executable_path/libmad.dylib @rpath/libmad.dylib ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
install_name_tool -change @executable_path/libogg.dylib @rpath/libogg.dylib ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
install_name_tool -change @executable_path/libvorbis.dylib @rpath/libvorbis.dylib ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
install_name_tool -change @executable_path/libvorbisfile.dylib @rpath/libvorbisfile.dylib ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
install_name_tool -change @executable_path/libxmp.dylib @rpath/libxmp.dylib ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

"../MSPBuildSystem/common/copy_dependencies.sh" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

cp -a MacOSX/SDL2.framework ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"