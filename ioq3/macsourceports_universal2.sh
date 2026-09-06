# game/app specific values
# note that for ioq3 some of these values are not used since it handles bundling differently. 
export PRODUCT_NAME="ioquake3"
export PROJECT_NAME="ioq3"
export PORT_NAME="ioquake3"
export ICONSFILENAME="ioquake3"
export EXECUTABLE_NAME="ioquake3"
export PKGINFO="APPLIOQ3"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.9"

cd ../../${PROJECT_NAME}

export APP_VERSION=`grep '^VERSION=' Makefile | sed -e 's/.*=\(.*\)/\1/'`
export RANLIB=/usr/bin/ranlib

# ioq3 has everything scripted out so we just need to delete the last build
# and fire off a script. Formerly the MSP build script recreated portions of
# ioq3's script and we evolved from there. Today this is no longer necessary. 

if [ -d build ]; then
	rm -rf build
fi

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel $NCPU

if [ -d "${BUILT_PRODUCTS_DIR}" ]; then
	rm -r "${BUILT_PRODUCTS_DIR}"
fi
mkdir "${BUILT_PRODUCTS_DIR}"
cp -R build/Release/"${WRAPPER_NAME}" "${BUILT_PRODUCTS_DIR}"

cp "../MSPBuildSystem/ioq3/ioquake3.icns" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
gsed -i 's|org.ioquake.ioquake3|com.macsourceports.ioquake3|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"
gsed -i 's|quake3_flat|ioquake3|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

export ENTITLEMENTS_FILE="misc/xcode/ioquake3/ioquake3.entitlements"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"