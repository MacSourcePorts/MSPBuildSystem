# game/app specific values
# note that for ioq3 some of these values are not used since it handles bundling differently. 
export APP_VERSION=`grep '^VERSION=' Makefile | sed -e 's/.*=\(.*\)/\1/'`
export PRODUCT_NAME="ioquake3"
export PROJECT_NAME="ioquake3"
export PORT_NAME="ioquake3"
export ICONSFILENAME="ioquake3"
export EXECUTABLE_NAME="ioquake3"
export PKGINFO="APPLIOQ3"
export GIT_DEFAULT_BRANCH="main"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

export APP_VERSION=`grep '^VERSION=' Makefile | sed -e 's/.*=\(.*\)/\1/'`

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

# skipping checkout since we just use the latest on this one

X86_64_MACOSX_VERSION_MIN="10.7"
ARM64_MACOSX_VERSION_MIN="11.0"

# x86_64 client and server
if [ -d build/release-release-x86_64 ]; then
rm -rf build/release-darwin-x86_64
fi
(ARCH=x86_64 CFLAGS=$X86_64_CFLAGS MACOSX_VERSION_MIN=$X86_64_MACOSX_VERSION_MIN make -j$NCPU) || exit 1;

# arm64 client and server
if [ -d build/release-release-arm64 ]; then
rm -rf build/release-darwin-arm64
fi
(ARCH=arm64 CFLAGS=$ARM64_CFLAGS MACOSX_VERSION_MIN=$ARM64_MACOSX_VERSION_MIN make -j$NCPU) || exit 1;

echo

# use the following shell script to build a universal 2 application bundle
export MACOSX_DEPLOYMENT_TARGET="10.7"
export MACOSX_DEPLOYMENT_TARGET_X86_64="$X86_64_MACOSX_VERSION_MIN"
export MACOSX_DEPLOYMENT_TARGET_ARM64="$ARM64_MACOSX_VERSION_MIN"
export MACOSX_BUNDLE_TYPE="universal2"

if [ -d build/release-darwin-universal2 ]; then
	rm -r build/release-darwin-universal2
fi

# ioq3 handles its own app bundling and lipo'ing so we do this
# instead of calling "../MSPBuildSystem/common/build_app_bundle.sh"
"./make-macosx-app.sh" release

if [ -d "${BUILT_PRODUCTS_DIR}" ]; then
rm -r "${BUILT_PRODUCTS_DIR}"
fi
mkdir "${BUILT_PRODUCTS_DIR}"
cp -R build/release-darwin-universal2/"${WRAPPER_NAME}" "${BUILT_PRODUCTS_DIR}"

export ENTITLEMENTS_FILE="misc/xcode/ioquake3/ioquake3.entitlements"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"