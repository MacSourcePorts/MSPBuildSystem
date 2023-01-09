# game/app specific values
export APP_VERSION="1.3"
export PRODUCT_NAME="daikatana"
export PROJECT_NAME="daikatana-1.3"
export PORT_NAME="Daikatana 1.3 Project"
export ICONSFILENAME="daikatana"
export EXECUTABLE_NAME="daikatana"
export PKGINFO="APPLDKTNA"
export GIT_TAG="QUAKE2_8_20"
export GIT_DEFAULT_BRANCH="master"
export GIT_TAG_XATRIX="XATRIX_2_11"
export GIT_TAG_ROGUE="ROGUE_2_10"

# constants
source ../common/constants.sh
source ../common/signing_values.local

# Main game compilation
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

rm -rf ${BUILT_PRODUCTS_DIR}

if [ ! -e ./patchdata/data/pak4.pak ]; then	
	echo "Make sure to have Daikatana 1.3 patchdata in ./patchdata/data/ !"
	exit 1
fi

set -e

if [ ! -d "./third_party" ] ; then
	./bootstrap.sh
fi

./gengitdate.sh

make clean
(OSTYPE=macos MACHTYPE=x86_64 GAME_STATIC=1 REF_STATIC_GL=1 AUDIO_STATIC_OPENAL=1 make STD_CXX=clang++)
(OSTYPE=macos MACHTYPE=arm64 GAME_STATIC=1 REF_STATIC_GL=1 AUDIO_STATIC_OPENAL=1 make STD_CXX=clang++)

cd bin/release-x86_64
mkdir -p "${EXECUTABLE_FOLDER_PATH}"
cp "${EXECUTABLE_NAME}" "${EXECUTABLE_FOLDER_PATH}"

mkdir -p "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls" || exit 1;
cp dlls/* "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls" || exit 1;

# dylibbundler needs a little nudge on these
install_name_tool -change ../bin/release-x86_64/dlls/ioncommon.dylib ../../bin/release-x86_64/dlls/ioncommon.dylib ${EXECUTABLE_FOLDER_PATH}/daikatana
install_name_tool -change ../../bin/release-x86_64/dlls/minizip.dylib ../../bin/release-x86_64/dlls/minizip.dylib ${EXECUTABLE_FOLDER_PATH}/daikatana
install_name_tool -change libopenal.1.dylib ../../third_party/x86_64/lib/libopenal.1.dylib ${EXECUTABLE_FOLDER_PATH}/daikatana
install_name_tool -change libalure.1.dylib ../../third_party/x86_64/lib/libalure.1.dylib ${EXECUTABLE_FOLDER_PATH}/daikatana
install_name_tool -change libopenal.1.dylib ../../third_party/x86_64/lib/libopenal.1.dylib ../../third_party/x86_64/lib/libalure.1.dylib

dylibbundler -od -b -x ./"${EXECUTABLE_FOLDER_PATH}"/"${EXECUTABLE_NAME}" -d ./"${EXECUTABLE_FOLDER_PATH}"/libs-x86_64/ -p @executable_path/libs-x86_64/ -s ../../third_party/x86_64/lib/
cd ../..

cd bin/release-arm64
mkdir -p "${EXECUTABLE_FOLDER_PATH}"
cp "${EXECUTABLE_NAME}" "${EXECUTABLE_FOLDER_PATH}"

mkdir -p "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls" || exit 1;
cp dlls/* "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls" || exit 1;

# dylibbundler needs a little nudge on these
install_name_tool -change ../bin/release-arm64/dlls/ioncommon.dylib ../../bin/release-arm64/dlls/ioncommon.dylib ${EXECUTABLE_FOLDER_PATH}/daikatana
install_name_tool -change ../../bin/release-arm64/dlls/minizip.dylib ../../bin/release-arm64/dlls/minizip.dylib ${EXECUTABLE_FOLDER_PATH}/daikatana
install_name_tool -change libopenal.1.dylib ../../third_party/arm64/lib/libopenal.1.dylib ${EXECUTABLE_FOLDER_PATH}/daikatana
install_name_tool -change libalure.1.dylib ../../third_party/arm64/lib/libalure.1.dylib ${EXECUTABLE_FOLDER_PATH}/daikatana
install_name_tool -change libopenal.1.dylib ../../third_party/arm64/lib/libopenal.1.dylib ../../third_party/arm64/lib/libalure.1.dylib

dylibbundler -od -b -x ./"${EXECUTABLE_FOLDER_PATH}"/"${EXECUTABLE_NAME}" -d ./"${EXECUTABLE_FOLDER_PATH}"/libs-arm64/ -p @executable_path/libs-arm64/
cd ../..

# create the app bundle
# since daikatana is all special I'm telling it to skip the lipo/dylibbundler parts
# (really it's that I don't want to spend the time to figure out how to shove it into the workflow)
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

#create any app-specific directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" || exit 1;
fi

if [ ! -d "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls" || exit 1;
fi

if [ ! -d "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/patchedData" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/patchedData" || exit 1;
fi

rsync -avz patchdata/data/* ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/patchedData

#lipo the executable
# TODO: fix this on build box (add arm64 stuff, do actual lipo)
lipo bin/release-x86_64/"${EXECUTABLE_FOLDER_PATH}"/daikatana bin/release-arm64/"${EXECUTABLE_FOLDER_PATH}"/daikatana -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/daikatana" -create
lipo bin/release-x86_64/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/dlls/ioncommon.dylib bin/release-arm64/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/dlls/ioncommon.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/ioncommon.dylib" -create
lipo bin/release-x86_64/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/dlls/language_english.dylib bin/release-arm64/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/dlls/language_english.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/language_english.dylib" -create
lipo bin/release-x86_64/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/dlls/minizip.dylib bin/release-arm64/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/dlls/minizip.dylib -output "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/minizip.dylib" -create
mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libs-x86_64"
cp -a bin/release-x86_64/"${EXECUTABLE_FOLDER_PATH}"/libs-x86_64/. "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libs-x86_64" || exit 1;
mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libs-arm64"
cp -a bin/release-arm64/"${EXECUTABLE_FOLDER_PATH}"/libs-arm64/. "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libs-arm64" || exit 1;


#sign and notarize
echo codesign --force --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/ioncommon.dylib
codesign --force --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/ioncommon.dylib

echo codesign --force --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/minizip.dylib
codesign --force --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/minizip.dylib

echo codesign --force --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/language_english.dylib
codesign --force --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/dlls/language_english.dylib

export ENTITLEMENTS_FILE="base/Daikatana/Daikatana.entitlements"
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"