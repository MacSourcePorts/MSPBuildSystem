# game/app specific values
export APP_VERSION="4.0.0.3"
export PRODUCT_NAME="DOOM64EXPlus"
export PROJECT_NAME="Doom64EX-Plus"
export PORT_NAME="DOOM64EXPlus"
export ICONSFILENAME="DOOM64EXPlus"
export EXECUTABLE_NAME="DOOM64EXPlus"
export GIT_TAG="4.0.0.3.SDL.3.2.10"
export GIT_DEFAULT_BRANCH="stable"

# constants
source ../common/constants.sh
cd ../../${PROJECT_NAME}

if [ -n "$3" ]; then
	export APP_VERSION="${3/v/}"
	export GIT_TAG="$3"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at: " "$APP_VERSION" / "$GIT_TAG"
    # # because we do a patch, we need to reset any changes
    # echo git reset --hard
    # git reset --hard

    # # reset to the main branch
    # echo git checkout ${GIT_DEFAULT_BRANCH}
    # git checkout ${GIT_DEFAULT_BRANCH}

    # # fetch the latest 
    # echo git pull
    # git pull

    # # check out the latest release tag
    # echo git checkout tags/${GIT_TAG}
    # git checkout tags/${GIT_TAG}
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
	SYMROOT=$PWD/${BUILT_PRODUCTS_DIR}

echo $PWD
echo mv ${BUILT_PRODUCTS_DIR}/Release/DOOM64EXPlus.app "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
mv ${BUILT_PRODUCTS_DIR}/Release/DOOM64EXPlus.app "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"

# mv "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libz.1.2.13.dylib"  "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
# mv "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libpng16.16.dylib"  "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
# mv "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libSDL2_net-2.0.0.dylib"  "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

# install_name_tool -change /opt/local/lib/libz.1.dylib @rpath/libz.1.2.13.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
# install_name_tool -change /opt/local/lib/libpng16.16.dylib @rpath/libpng16.16.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
# install_name_tool -change /opt/local/lib/libSDL2_net-2.0.0.dylib @rpath/libSDL2_net-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
# install_name_tool -change @rpath/libfluidsynth.3.dylib @rpath/libfluidsynth.3.2.3.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
# install_name_tool -change @executable_path/libz.1.2.13.dylib @rpath/libz.1.2.13.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libpng16.16.dylib"
# install_name_tool -change @executable_path/libSDL2-2.0.0.dylib @rpath/libSDL3.0.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libSDL2_net-2.0.0.dylib"

"../MSPBuildSystem/common/copy_dependencies.sh" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"