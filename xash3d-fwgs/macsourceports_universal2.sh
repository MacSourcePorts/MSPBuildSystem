# game/app specific values
export APP_VERSION="0.20"
export ICONSFILENAME="xash3d-fwgs"
export PRODUCT_NAME="Xash3D-FWGS"
export PROJECT_NAME="xash3d-fwgs"
export PORT_NAME="Xash3D-FWGS"
export EXECUTABLE_NAME="xash3d"
export PKGINFO="APPLMLST"
export GIT_DEFAULT_BRANCH="main"
export ENTITLEMENTS_FILE="../MSPBuildSystem/xash3d-fwgs/xash3d-fwgs.entitlements"

#constants
source ../common/constants.sh

# first, we get to compile the SDK

cd ../../hlsdk-portable

# todo: both archs
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake ..
make -j$NCPU

mv cl_dll cl_dlls
mv cl_dlls/client.dylib cl_dlls/client_arm64.dylib
rm cl_dlls/cmake_install.cmake
rm -rf cl_dlls/CMakeFiles
rm cl_dlls/Makefile

mv dlls/hl.dylib dlls/hl_arm64.dylib
rm dlls/cmake_install.cmake
rm -rf dlls/CMakeFiles
rm dlls/Makefile

cd ../../${PROJECT_NAME}

# # reset to the main branch
# echo git checkout ${GIT_DEFAULT_BRANCH}
# git checkout ${GIT_DEFAULT_BRANCH}

# # fetch the latest 
# echo git pull
# git pull

rm -rf build
rm -rf ${BUILT_PRODUCTS_DIR}

# rm -rf ${X86_64_BUILD_FOLDER}
# mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

(PATH="/opt/homebrew/Cellar/binutils/2.39_1/bin:$PATH" ./waf configure --64bits -T release)
./waf build
./waf install --destdir=${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
./waf install --destdir=${ARM64_BUILD_FOLDER}/install

mkdir ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/cl_dlls
cp -a ../hlsdk-portable/${ARM64_BUILD_FOLDER}/cl_dlls/* ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/cl_dlls

mkdir ${ARM64_BUILD_FOLDER}/install/cl_dlls
cp -a ../hlsdk-portable/${ARM64_BUILD_FOLDER}/cl_dlls/* ${ARM64_BUILD_FOLDER}/install/cl_dlls

mkdir ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/dlls
cp -a ../hlsdk-portable/${ARM64_BUILD_FOLDER}/dlls/* ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/dlls

mkdir ${ARM64_BUILD_FOLDER}/install/dlls
cp -a ../hlsdk-portable/${ARM64_BUILD_FOLDER}/dlls/* ${ARM64_BUILD_FOLDER}/install/dlls

# echo cp -a /Users/tomkidd/.xash3d/valve/* ${ARM64_BUILD_FOLDER}/install/valve
# cp -a /Users/tomkidd/.xash3d/valve/* ${ARM64_BUILD_FOLDER}/install/valve

if [ ! -d "${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" ]; then
	mkdir -p "${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" || exit 1;
fi
cp -a ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/valve ${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}

cp ../MSPBuildSystem/${PROJECT_NAME}/${ICONSFILENAME}.icns ${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}

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
    <string>11.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>LSApplicationCategoryType</key>
	<string>public.app-category.games</string>
    <key>NSHighResolutionCapable</key>
    <${HIGH_RESOLUTION_CAPABLE}/>
</dict>
</plist>
"
echo "${PLIST}" > "${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/Info.plist"

export BUILT_PRODUCTS_DIR="build-arm64"

# create the app bundle
# export BUNDLE_ID="com.macsourceports.uqm"
# "../MSPBuildSystem/common/build_app_bundle.sh"

cd ${BUILT_PRODUCTS_DIR}
dylibbundler -od -b -x "./${EXECUTABLE_FOLDER_PATH}/libxash.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
cd ..


#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"