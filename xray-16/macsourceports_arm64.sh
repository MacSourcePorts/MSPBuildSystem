# game/app specific values
export APP_VERSION="1.6"
export PRODUCT_NAME="openxray"
export PROJECT_NAME="xray-16"
export PORT_NAME="OpenXRay"
export ICONSFILENAME="openxray"
export EXECUTABLE_NAME="xr_3da"
export PKGINFO="APPLOPXR"
export GIT_TAG="1.6"
export GIT_DEFAULT_BRANCH="dev"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

# check out the latest release tag
# echo git checkout tags/${GIT_TAG}
# git checkout tags/${GIT_TAG}

export MACOSX_DEPLOYMENT_TARGET=10.9

# For some reason everything is in a top-level bin folder
rm -rf "bin"

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}

cmake \
-DCMAKE_OSX_ARCHITECTURES=arm64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
-DCMAKE_FIND_FRAMEWORK=LAST \
-DLZO_INCLUDE_DIR=/opt/homebrew/include \
-DLZO_LIBRARY=/opt/homebrew/lib/liblzo2.dylib \
..
cmake --build . -j $NCPU
mkdir -p "${EXECUTABLE_FOLDER_PATH}"
mkdir -p "${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
# mkdir -p "${CONTENTS_FOLDER_PATH}/libs"

cp "../bin/arm64/Release/${EXECUTABLE_NAME}" "${EXECUTABLE_FOLDER_PATH}"
cp ../bin/arm64/Release/*.dylib "${EXECUTABLE_FOLDER_PATH}"
cp ../bin/arm64/Release/*.a "${EXECUTABLE_FOLDER_PATH}"
cp /opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib "${EXECUTABLE_FOLDER_PATH}"
cp /opt/homebrew/opt/libogg/lib/libogg.0.dylib "${EXECUTABLE_FOLDER_PATH}"
cp /opt/homebrew/opt/libvorbis/lib/libvorbis.0.dylib "${EXECUTABLE_FOLDER_PATH}"
cp /opt/homebrew/opt/libvorbis/lib/libvorbisfile.3.dylib "${EXECUTABLE_FOLDER_PATH}"
cp /opt/homebrew/opt/jpeg-turbo/lib/libjpeg.8.dylib "${EXECUTABLE_FOLDER_PATH}"
cp /opt/homebrew/opt/lzo/lib/liblzo2.2.dylib "${EXECUTABLE_FOLDER_PATH}"
cp /opt/homebrew/opt/theora/lib/libtheora.0.dylib "${EXECUTABLE_FOLDER_PATH}"

install_name_tool -add_rpath @executable_path/. ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
install_name_tool -change "/opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib" "@rpath/libSDL2-2.0.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
install_name_tool -change "/opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib" "@rpath/libSDL2-2.0.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrAICore.dylib"
install_name_tool -change "/opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib" "@rpath/libSDL2-2.0.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrCDB.dylib"
install_name_tool -change "/opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib" "@rpath/libSDL2-2.0.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrGame.dylib"
install_name_tool -change "/opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib" "@rpath/libSDL2-2.0.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrMaterialSystem.dylib"
install_name_tool -change "/opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib" "@rpath/libSDL2-2.0.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrNetServer.dylib"
install_name_tool -change "/opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib" "@rpath/libSDL2-2.0.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrParticles.dylib"
install_name_tool -change "/opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib" "@rpath/libSDL2-2.0.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrRender_GL.dylib"
install_name_tool -change "/opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib" "@rpath/libSDL2-2.0.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrScriptEngine.dylib"
install_name_tool -change "/opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib" "@rpath/libSDL2-2.0.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrUICore.dylib"
install_name_tool -change "/opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib" "@rpath/libSDL2-2.0.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrSound.dylib"
install_name_tool -change "/opt/homebrew/opt/libogg/lib/libogg.0.dylib" "@rpath/libogg.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrSound.dylib"
install_name_tool -change "/opt/homebrew/opt/libvorbis/lib/libvorbis.0.dylib" "@rpath/libvorbis.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrSound.dylib"
install_name_tool -change "/opt/homebrew/opt/libvorbis/lib/libvorbisfile.3.dylib" "@rpath/libvorbisfile.3.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrSound.dylib"
install_name_tool -change "/opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib" "@rpath/libSDL2-2.0.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrCore.dylib"
install_name_tool -change "/opt/homebrew/opt/jpeg-turbo/lib/libjpeg.8.dylib" "@rpath/libjpeg.8.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrCore.dylib"
install_name_tool -change "/opt/homebrew/opt/lzo/lib/liblzo2.2.dylib" "@rpath/liblzo2.2.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrCore.dylib"
install_name_tool -change "/opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib" "@rpath/libSDL2-2.0.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrEngine.dylib"
install_name_tool -change "/opt/homebrew/opt/libogg/lib/libogg.0.dylib" "@rpath/libogg.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrEngine.dylib"
install_name_tool -change "/opt/homebrew/opt/theora/lib/libtheora.0.dylib" "@rpath/libtheora.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/xrEngine.dylib"

install_name_tool -change "/opt/homebrew/opt/libogg/lib/libogg.0.dylib" "@rpath/libogg.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/libvorbis.0.dylib"
install_name_tool -change "/opt/homebrew/Cellar/libvorbis/1.3.7/lib/libvorbis.0.dylib" "@rpath/libvorbis.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/libvorbisfile.3.dylib"
install_name_tool -change "/opt/homebrew/opt/libogg/lib/libogg.0.dylib" "@rpath/libogg.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/libvorbisfile.3.dylib"
install_name_tool -change "/opt/homebrew/opt/libogg/lib/libogg.0.dylib" "@rpath/libogg.0.dylib" "./${EXECUTABLE_FOLDER_PATH}/libtheora.0.dylib"

echo -n ${PKGINFO} > "${CONTENTS_FOLDER_PATH}/PkgInfo" || exit 1;

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
echo "${PLIST}" > "${CONTENTS_FOLDER_PATH}/Info.plist"

# doing the icons last in case we need to overwrite theirs
cp "../${ICONSDIR}/${ICONS}" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}" || exit 1;

mkdir -p extras
cp -rf ../res/gamedata extras
cp ../res/fsgame.ltx extras
ditto -ck --rsrc --sequesterRsrc extras openxray-extras.zip

cd ..

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"
cp -a ${BUILT_PRODUCTS_DIR}/openxray-extras.zip "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}_${DATE_TIMESTAMP}"

echo "Cleaning up"
rm -rf ${BUILT_PRODUCTS_DIR}