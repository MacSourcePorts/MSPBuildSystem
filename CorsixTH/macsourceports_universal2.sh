# game/app specific values
export APP_VERSION="0.68.0"
export PRODUCT_NAME="CorsixTH"
export PROJECT_NAME="CorsixTH"
export PORT_NAME="CorsixTH"
export ICONSFILENAME="CorsixTH"
export EXECUTABLE_NAME="CorsixTH"
export PKGINFO="APPLCTH"
export GIT_TAG="v0.68.0"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh
source ../common/signing_values.local

export ENTITLEMENTS_FILE="CorsixTH.entitlements"
export HIGH_RESOLUTION_CAPABLE="true"

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
cp -rf "../MSPBuildSystem/CorsixTH/macos_luarocks" "scripts"

# Turning off the bundling for now
gsed -i '/FIXUP_BUNDLE(.*CorsixTH\.app.*)/d' CorsixTH/CMakeLists.txt

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake, perform builds with make
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake \
.. \
-DDISABLE_WERROR=1 \
-DCMAKE_OSX_ARCHITECTURES=arm64  \
-DCMAKE_INSTALL_PREFIX=${SCRIPT_DIR}/${ARM64_BUILD_FOLDER} \
-DCMAKE_PREFIX_PATH=/Users/tomkidd/Downloads/libs/arm64 \
-DWITH_LUAROCKS=on \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 \
-DLUA_LIBRARY=/opt/Homebrew/lib/liblua.5.4.dylib \
-DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
make CorsixTH -j8
make install

cd ..

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake \
.. \
-DDISABLE_WERROR=1 \
-DCMAKE_OSX_ARCHITECTURES=x86_64  \
-DCMAKE_INSTALL_PREFIX=${SCRIPT_DIR}/${X86_64_BUILD_FOLDER} \
-DCMAKE_PREFIX_PATH=/Users/tomkidd/Downloads/libs/x86_64 \
-DWITH_LUAROCKS=on \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 \
-DLUA_LIBRARY=/usr/local/lib/liblua.5.4.dylib \
-DLUA_PROGRAM_PATH=/usr/local/bin/lua \
-DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
make CorsixTH -j8
make install

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

lipo ${X86_64_BUILD_FOLDER}/${WRAPPER_NAME}/Contents/Resources/lpeg.so ${ARM64_BUILD_FOLDER}/${WRAPPER_NAME}/Contents/Resources/lpeg.so -output "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/lpeg.so" -create
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/lpeg.so

lipo ${X86_64_BUILD_FOLDER}/${WRAPPER_NAME}/Contents/Resources/lfs.so ${ARM64_BUILD_FOLDER}/${WRAPPER_NAME}/Contents/Resources/lfs.so -output "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/lfs.so" -create
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}/Contents/Resources/lfs.so

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" #"skipcleanup"