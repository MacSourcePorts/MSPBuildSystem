# game/app specific values
# note that for ioq3 some of these values are not used since it handles bundling differently. 
export APP_VERSION=`grep '^VERSION=' Makefile | sed -e 's/.*=\(.*\)/\1/'`
export PRODUCT_NAME="ioquake3"
export PROJECT_NAME="ioq3"
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

# ioq3 has everything scripted out so we just need to delete the last build
# and fire off a script. Formerly the MSP build script recreated portions of
# ioq3's script and we evolved from there. Today this is no longer necessary. 

if [ -d build ]; then
	rm -rf build
fi

"./make-macosx-ub2.sh" release

if [ -d "${BUILT_PRODUCTS_DIR}" ]; then
	rm -r "${BUILT_PRODUCTS_DIR}"
fi
mkdir "${BUILT_PRODUCTS_DIR}"
cp -R build/release-darwin-universal2/"${WRAPPER_NAME}" "${BUILT_PRODUCTS_DIR}"

cp "../MSPBuildSystem/ioq3/ioquake3.icns" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
gsed -i 's|org.ioquake.ioquake3|com.macsourceports.ioquake3|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"
gsed -i 's|quake3_flat|ioquake3|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

export ENTITLEMENTS_FILE="misc/xcode/ioquake3/ioquake3.entitlements"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"