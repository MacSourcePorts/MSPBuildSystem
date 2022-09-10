# This file is for the GL version of Hexen II. 
# As of right now the game has issues on Apple Silicon

# game/app specific values
export APP_VERSION="1.5.9-gl"
export PRODUCT_NAME="uhexen2"
export PROJECT_NAME="uhexen2"
export PORT_NAME="uHexen2"
export ICONSFILENAME="uhexen2"
export EXECUTABLE_NAME="glhexen2"
export PKGINFO="APPLHXN2"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh
source ../common/signing_values.local

export HIGH_RESOLUTION_CAPABLE="false"

cd ../../${PROJECT_NAME}

# # reset to the main branch
# echo git checkout ${GIT_DEFAULT_BRANCH}
# git checkout ${GIT_DEFAULT_BRANCH}

# # fetch the latest 
# echo git pull
# git pull

# # check out the latest release tag
# echo git checkout tags/${GIT_TAG}
# git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

cd engine/hexen2
make clean
make MACH_TYPE=x86_64 glh2
cp glhexen2 ../../${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cd ../../

# Because this uses Make and doesn't do its own packaging we have to do some of it manually here
# since there's no Apple Silicon build

cd ${BUILT_PRODUCTS_DIR}
dylibbundler -od -b -x "./${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
cd ..

cp "../MSPBuildSystem/uHexen2/${ICONS}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}"
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
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"