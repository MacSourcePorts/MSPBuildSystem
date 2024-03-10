# game/app specific values
export APP_VERSION="0.67"
export PRODUCT_NAME="CorsixTH"
export PROJECT_NAME="CorsixTH"
export PORT_NAME="CorsixTH"
export ICONSFILENAME="Icon"
export EXECUTABLE_NAME="CorsixTH"
export PKGINFO="APPLCTH"
export GIT_TAG="v0.67"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh
source ../common/signing_values.local

export ENTITLEMENTS_FILE="CorsixTH.entitlements"
export HIGH_RESOLUTION_CAPABLE="true"
export ARCH_FOLDER="/x86_64"
export ARCH_SUFFIX="-x86_64"

cd ../../${PROJECT_NAME}
SCRIPT_DIR=$PWD

# reset to the main branch
echo git restore .
git restore .
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

# check out the latest release tag
echo git checkout tags/${GIT_TAG}
git checkout tags/${GIT_TAG}

# hotfix for issue with luarocks script
echo cp -rf "../MSPBuildSystem/CorsixTH/macos_luarocks" "scripts"
cp -rf "../MSPBuildSystem/CorsixTH/macos_luarocks" "scripts"
echo cp -rf "../MSPBuildSystem/CorsixTH/CMakeLists.txt" "CorsixTH"
cp -rf "../MSPBuildSystem/CorsixTH/CMakeLists.txt" "CorsixTH"

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake, perform builds with make
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake \
.. \
-DDISABLE_WERROR=1 \
-DCMAKE_OSX_ARCHITECTURES=x86_64  \
-DCMAKE_INSTALL_PREFIX=${SCRIPT_DIR}/${BUILT_PRODUCTS_DIR} \
-DWITH_LUAROCKS=on \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 \
-DLUA_LIBRARY=/usr/local/lib/liblua.5.4.dylib \
-DLUA_PROGRAM_PATH=/usr/local/bin/lua \
-DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
make CorsixTH -j8
make install

cd ..

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
    <string>10.7</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <${HIGH_RESOLUTION_CAPABLE}/>
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.games</string>
</dict>
</plist>
"
echo "${PLIST}" > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

cd ${BUILT_PRODUCTS_DIR}
dylibbundler -of -cd -b -x "./${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
cd ..
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/ssl.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/lpeg.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/lfs.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/mime/core.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/socket/core.so

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" # "skipcleanup"