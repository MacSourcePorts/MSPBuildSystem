# game/app specific values
export APP_VERSION="0.9.6"
export PRODUCT_NAME="OpenJKDF2"
export PROJECT_NAME="OpenJKDF2"
export PORT_NAME="OpenJKDF2"
export ICONSFILENAME="OpenJKDF2"
export EXECUTABLE_NAME="openjkdf2-64"
export PKGINFO="APPLJKDF2"
export GIT_TAG="v0.9.6"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.15"

cd ../../${PROJECT_NAME}

if [ -n "$3" ]; then
	export APP_VERSION="${3/v/}"
	export GIT_TAG="$3"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"
    # reset to the main branch
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}

    # fetch the latest 
    echo git pull
    git pull

    # check out the latest release tag
    echo git checkout tags/${GIT_TAG}
    git checkout tags/${GIT_TAG}

fi

rm -rf ${BUILT_PRODUCTS_DIR}

#because this port does so much of the packaging itself all we need to do is run the script
./distpkg_macos.sh

mkdir ${BUILT_PRODUCTS_DIR}
mv macos-debug.tar.gz ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
tar -xvf macos-debug.tar.gz
mv ${PRODUCT_NAME}_universal.app ${WRAPPER_NAME}
cd ..

cp ../MSPBuildSystem/${PROJECT_NAME}/${ICONSFILENAME}.icns ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}

PLIST="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>CFBundleExecutable</key>
    <string>${EXECUTABLE_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>${ICONSFILENAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${PRODUCT_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${APP_VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${APP_VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>${MINIMUM_SYSTEM_VERSION}</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <${HIGH_RESOLUTION_CAPABLE}/>
	<key>CSResourcesFileMapped</key>
	<true/>
	<key>SDL_FILESYSTEM_BASE_DIR_TYPE</key>
	<string>bundle</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.games</string>${EXTRA_INFO_PLIST_ENTRIES}
</dict>
</plist>
"
echo "${PLIST}" > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

install_name_tool -add_rpath @executable_path/. ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}

# For some reason libcrypto is misnamed
mv ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libcrypto.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libcrypto.3.dylib

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"