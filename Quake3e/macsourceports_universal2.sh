# game/app specific values
# note that for Quake3e some of these values are not used since it handles bundling differently. 
export PRODUCT_NAME="Quake3e"
export PROJECT_NAME="Quake3e"
export PORT_NAME="Quake3e"
export ICONSFILENAME="Quake3e"
export EXECUTABLE_NAME="Quake3e"
export PKGINFO="APPLQ3E"

#constants
source ../common/constants.sh
export MACOSX_DEPLOYMENT_TARGET="10.9"
export CFLAGS=-mmacosx-version-min=10.9
export LDFLAGS=-mmacosx-version-min=10.9
cd ../../${PROJECT_NAME}

export APP_VERSION="1.32e"

export RANLIB=/usr/bin/ranlib

if [ -d build ]; then
	rm -rf build
fi

"./make-macosx-ub2.sh" release

if [ -d "${BUILT_PRODUCTS_DIR}" ]; then
	rm -r "${BUILT_PRODUCTS_DIR}"
fi
mkdir "${BUILT_PRODUCTS_DIR}"
cp -R build/release-darwin-universal2/"${WRAPPER_NAME}" "${BUILT_PRODUCTS_DIR}"

cp "../MSPBuildSystem/Quake3e/Quake3e.icns" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
gsed -i 's|org.ioquake.Quake3e|com.macsourceports.Quake3e|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"
gsed -i 's|quake3_flat|Quake3e|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

export ENTITLEMENTS_FILE="../MSPBuildSystem/Quake3e/Quake3e.entitlements"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" "entitlements"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"