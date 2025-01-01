# As of right now this only builds on the host architecture
# I believe to fix it the project needs to pass architecture info to the Rust compiler it uses for static libraries.

# game/app specific values
export APP_VERSION="0.21.0"
export PRODUCT_NAME="ja2-stracciatella"
export PROJECT_NAME="ja2-stracciatella"
export PORT_NAME="JA2 Stracciatella"
export ICONSFILENAME="ja2-stracciatella"
export EXECUTABLE_NAME="ja2-launcher"
export PKGINFO="APPLJA2"
export GIT_DEFAULT_BRANCH="master"
export ENTITLEMENTS_FILE="../MSPBuildSystem/ja2-stracciatella/ja2-stracciatella.entitlements"
export GIT_TAG="v0.21.0"

#constants
source ../common/constants.sh
source ../common/signing_values.local

export HIGH_RESOLUTION_CAPABLE="true"

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
mkdir -p ${BUILT_PRODUCTS_DIR}
mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
mkdir -p ${EXECUTABLE_FOLDER_PATH}
mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchain-macos.cmake  -DCPACK_GENERATOR=Bundle -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13 ..
make

cd ..

cp ${ARM64_BUILD_FOLDER}/ja2 "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
cp ${ARM64_BUILD_FOLDER}/ja2-launcher "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    install_name_tool -change @rpath/SDL2.framework/Versions/A/SDL2 @rpath/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2"
    install_name_tool -change @rpath/SDL2.framework/Versions/A/SDL2 @rpath/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2-launcher"

    install_name_tool -add_rpath @executable_path/../Frameworks/. ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2
    install_name_tool -add_rpath @executable_path/../Frameworks/. ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2-launcher

    "../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2
    "../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2-launcher
else
    install_name_tool -change @rpath/SDL2.framework/Versions/A/SDL2 /opt/homebrew/lib/libSDL2.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2"
    install_name_tool -change @rpath/SDL2.framework/Versions/A/SDL2 /opt/homebrew/lib/libSDL2.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2-launcher"

    cd ${BUILT_PRODUCTS_DIR}
    dylibbundler -od -b -x "./${EXECUTABLE_FOLDER_PATH}/ja2" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
    dylibbundler -od -b -x "./${EXECUTABLE_FOLDER_PATH}/ja2-launcher" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
    cd ..
fi

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ja2-launcher
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libSDL2-2.0.0.dylib
else
    codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libs-arm64/libSDL2-2.0.0.dylib
fi

cp "../MSPBuildSystem/${PROJECT_NAME}/${ICONS}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}"
echo -n ${PKGINFO} > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/PkgInfo" || exit 1;

# create Info.Plist
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

# echo cp assets/distr-files-mac/ja2-startup.sh "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
# cp assets/distr-files-mac/ja2-startup.sh "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

# chmod +x "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

cp assets/distr-files-mac/README.txt "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/"

cp changes.md "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"

mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/externalized"
cp -a ${ARM64_BUILD_FOLDER}/externalized/* "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/externalized"

mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/mods"
cp -a ${ARM64_BUILD_FOLDER}/mods/* "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/mods"

mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/unittests"
cp -a ${ARM64_BUILD_FOLDER}/unittests/* "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/unittests"

echo "bundle done."

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"