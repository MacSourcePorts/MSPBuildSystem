# game/app specific values
export APP_VERSION="ssse-1.1"
export PRODUCT_NAME="ssam-tse"
export PROJECT_NAME="Serious-Engine"
export PORT_NAME="Serious Engine"
export ICONSFILENAME="ssse"
export EXECUTABLE_NAME="ssam"
export PKGINFO="APPLSSSE"
export GIT_TAG="1.5.2"
export GIT_DEFAULT_BRANCH="master"
export ENTITLEMENTS_FILE="../MSPBuildSystem/Serious-Engine/Serious-Engine.entitlements"

#constants
source ../common/constants.sh
source ../common/signing_values.local

cd ../../${PROJECT_NAME}

# reset to the main branch
# echo git checkout ${GIT_DEFAULT_BRANCH}
# git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
# echo git pull
# git pull

# check out the latest release tag
# NOTE: skipping for now until I do a PR to search in the app bundle for the game files.
# echo git checkout tags/${GIT_TAG}
# git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
mkdir -p "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}"

# create makefiles with cmake
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_OSX_ARCHITECTURES=x86_64 ../Sources -DCMAKE_PREFIX_PATH=/usr/local
mkdir -p ${EXECUTABLE_FOLDER_PATH}
mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}

# perform builds with make
make -j$NCPU
cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
cp Debug/* ${UNLOCALIZED_RESOURCES_FOLDER_PATH}

cd ..

cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/* ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}

cd ${BUILT_PRODUCTS_DIR}
dylibbundler -od -b -x "./${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
cd ..

# sign any app-specific libraries
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libEntitiesMP.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libGameMP.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libShaders.dylib

# copy any app-specific libraries
# we're doing things the hard way here because these aren't linked in but they need to be in the same dir
cp /usr/local/lib/libvorbis.dylib ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cp /usr/local/lib/libvorbisfile.dylib ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
install_name_tool -change /usr/local/Cellar/libvorbis/1.3.7/lib/libvorbis.0.dylib @executable_path/../Resources/libvorbis.dylib ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisfile.dylib
cp /usr/local/lib/libogg.dylib ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cp /usr/local/lib/libvorbisenc.dylib ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbis.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisfile.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libogg.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/libvorbisenc.dylib

cp "../MSPBuildSystem/Serious-Engine/${ICONS}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}"
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
</dict>
</plist>
"
echo "${PLIST}" > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

echo "bundle done."

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"