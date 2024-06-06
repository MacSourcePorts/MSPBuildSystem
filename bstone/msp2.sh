# game/app specific values
export APP_VERSION="1.2.12"
export PRODUCT_NAME="bstone"
export PROJECT_NAME="bstone"
export PORT_NAME="bstone"
export ICONSFILENAME="bstone"
export EXECUTABLE_NAME="bstone"
export PKGINFO="APPLROTT"
export GIT_DEFAULT_BRANCH="develop"

#constants
source ../common/constants.sh

# this port is not HiDPI aware
export HIGH_RESOLUTION_CAPABLE="false"

cd ../../${PROJECT_NAME}

# reset to the main branch
# echo git checkout ${GIT_DEFAULT_BRANCH}
# git checkout ${GIT_DEFAULT_BRANCH}

# # fetch the latest 
# echo git pull
# git pull

# create makefiles with cmake, perform builds with make
rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DMACOS_APP_BUNDLE=ON \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
-DCMAKE_CXX_STANDARD=11 \
..
make -j$NCPU
install_name_tool -add_rpath @executable_path/. src/${EXECUTABLE_NAME}
cp src/${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
cp /usr/local/lib/libSDL2-2.0.0.dylib ${EXECUTABLE_FOLDER_PATH}

cd ..

# create the app bundle
# make the app bundle directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" || exit 1;
fi
if [ ! -d "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" || exit 1;
fi

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

# doing the icons last in case we need to overwrite theirs
cp "${ICONSDIR}/${ICONS}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}" || exit 1;

echo "bundle done."
# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"