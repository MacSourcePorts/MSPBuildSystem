# game/app specific values
# note that for iortcw some of these values are not used since it handles bundling differently. 
export APP_VERSION="1.51d"
export PRODUCT_NAME="iowolfsp"
export PROJECT_NAME="iortcw"
export PORT_NAME="iortcw"
export ICONSFILENAME="iortcwsp"
export EXECUTABLE_NAME="iowolfsp"
export PKGINFO="APPLIORTCW"
export COPYRIGHT_TEXT="Return to Castle Wolfenstein Copyright © 1999-2000 id Software, Inc. All rights reserved."

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

# skipping checkout since we just use the latest on this one

X86_64_MACOSX_VERSION_MIN="10.9"
ARM64_MACOSX_VERSION_MIN="11.0"

# creating the "release" folder here since there's two apps involved. 
if [ -d "${BUILT_PRODUCTS_DIR}" ]; then
rm -r "${BUILT_PRODUCTS_DIR}"
fi
mkdir "${BUILT_PRODUCTS_DIR}"

# Single Player

cd SP

# x86_64 client and server
if [ -d build/release-darwin-x86_64 ]; then
rm -rf build/release-darwin-x86_64
fi
(ARCH=x86_64 CFLAGS=$X86_64_CFLAGS MACOSX_VERSION_MIN=$X86_64_MACOSX_VERSION_MIN make -j$NCPU) || exit 1;

# arm64 client and server
if [ -d build/release-darwin-arm64 ]; then
rm -rf build/release-darwin-arm64
fi
(ARCH=arm64 CFLAGS=$ARM64_CFLAGS MACOSX_VERSION_MIN=$ARM64_MACOSX_VERSION_MIN make -j$NCPU) || exit 1;

# use the following shell script to build a universal 2 application bundle
export MACOSX_DEPLOYMENT_TARGET="10.7"
export MACOSX_DEPLOYMENT_TARGET_X86_64="$X86_64_MACOSX_VERSION_MIN"
export MACOSX_DEPLOYMENT_TARGET_ARM64="$ARM64_MACOSX_VERSION_MIN"

if [ -d build/release-darwin-universal2 ]; then
	rm -r build/release-darwin-universal2
fi

# ioq3 handles its own app bundling and lipo'ing so we do this
# instead of calling "../MSPScripts/build_app_bundle.sh"
"./make-macosx-app.sh" release

cp -R build/release-darwin-universal2/"${WRAPPER_NAME}" "../${BUILT_PRODUCTS_DIR}"

cd ..

export ENTITLEMENTS_FILE="SP/misc/xcode/iortcw/iortcw.entitlements"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"

# Multiplayer

cd MP
export PRODUCT_NAME="iowolfmp"
export EXECUTABLE_NAME="iowolfmp"
export WRAPPER_NAME="${PRODUCT_NAME}.app"
export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"

# x86_64 client and server
if [ -d build/release-darwin-x86_64 ]; then
rm -rf build/release-darwin-x86_64
fi
(ARCH=x86_64 CFLAGS=$X86_64_CFLAGS MACOSX_VERSION_MIN=$X86_64_MACOSX_VERSION_MIN make -j$NCPU) || exit 1;

# arm64 client and server
if [ -d build/release-darwin-arm64 ]; then
rm -rf build/release-darwin-arm64
fi
(ARCH=arm64 CFLAGS=$ARM64_CFLAGS MACOSX_VERSION_MIN=$ARM64_MACOSX_VERSION_MIN make -j$NCPU) || exit 1;

# use the following shell script to build a universal 2 application bundle
export MACOSX_DEPLOYMENT_TARGET="10.7"
export MACOSX_DEPLOYMENT_TARGET_X86_64="$X86_64_MACOSX_VERSION_MIN"
export MACOSX_DEPLOYMENT_TARGET_ARM64="$ARM64_MACOSX_VERSION_MIN"

if [ -d build/release-darwin-universal2 ]; then
	rm -r build/release-darwin-universal2
fi

# ioq3 handles its own app bundling and lipo'ing so we do this
# instead of calling "../MSPScripts/build_app_bundle.sh"
"./make-macosx-app.sh" release

cp -R build/release-darwin-universal2/"${WRAPPER_NAME}" "../${BUILT_PRODUCTS_DIR}"

cd ..

export ENTITLEMENTS_FILE="MP/misc/xcode/iortcw/iortcw.entitlements"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipdelete"