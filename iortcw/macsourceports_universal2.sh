# game/app specific values
# note that for iortcw some of these values are not used since it handles bundling differently. 
# export APP_VERSION="1.51d"
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

export APP_VERSION=`grep '^VERSION=' Makefile | sed -e 's/.*=\(.*\)/\1/'`


if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	echo "Skipping git because we're on the build server"
	
	export RANLIB=/usr/bin/ranlib
	export USE_INTERNAL_FREETYPE=0
	export USE_INTERNAL_ZLIB=0
	export PKG_CONFIG=pkg-config
else
	# reset to the main branch
	echo git checkout ${GIT_DEFAULT_BRANCH}
	git checkout ${GIT_DEFAULT_BRANCH}

	# fetch the latest 
	echo git pull
	git pull

	# skipping checkout since we just use the latest on this one
fi

# iortcw has everything scripted out so we just need to delete the last build
# and fire off a script. Formerly the MSP build script recreated portions of
# iortcw's script and we evolved from there. Today this is no longer necessary. 

# For now, copying over the new ub2 script manually
cp "../MSPBuildSystem/iortcw/make-macosx-ub2.sh" SP
cp "../MSPBuildSystem/iortcw/make-macosx-app-sp.sh" SP/make-macosx-app.sh
cp "../MSPBuildSystem/iortcw/make-macosx-ub2.sh" MP
cp "../MSPBuildSystem/iortcw/make-macosx-app-mp.sh" MP/make-macosx-app.sh

# creating the "release" folder here since there's two apps involved. 
if [ -d "${BUILT_PRODUCTS_DIR}" ]; then
rm -r "${BUILT_PRODUCTS_DIR}"
fi
mkdir "${BUILT_PRODUCTS_DIR}"

# Single Player

cd SP

if [ -d build ]; then
	rm -rf build
fi

"./make-macosx-ub2.sh" release

cp -R build/release-darwin-universal2/"${WRAPPER_NAME}" "../${BUILT_PRODUCTS_DIR}"

cd ..

"../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
"../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/renderer_sp_opengl1.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH} 
cp "../MSPBuildSystem/iortcw/iortcwsp.icns" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
gsed -i 's|org.iortcw.iowolfsp|com.macsourceports.iowolfsp|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"
gsed -i 's|<string>iortcw</string>|<string>iortcwsp</string>|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

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
export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
export FRAMEWORKS_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Frameworks"

if [ -d build ]; then
	rm -rf build
fi

"./make-macosx-ub2.sh" release

cp -R build/release-darwin-universal2/"${WRAPPER_NAME}" "../${BUILT_PRODUCTS_DIR}"

cd ..

"../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
"../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/renderer_mp_opengl1.dylib ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH} 
cp "../MSPBuildSystem/iortcw/iortcwmp.icns" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
gsed -i 's|org.iortcw.iowolfmp|com.macsourceports.iowolfmp|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"
gsed -i 's|<string>iortcw</string>|<string>iortcwmp</string>|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

export ENTITLEMENTS_FILE="MP/misc/xcode/iortcw/iortcw.entitlements"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipdelete"