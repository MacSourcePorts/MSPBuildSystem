# game/app specific values
# Built from opentyrian/opentyrian's latest release tag (v2.1.20260913 -> 2.1.20260913)
APP_VERSION=`git -C ../../opentyrian describe --tags --abbrev=0 --match 'v2.1.*'`
export APP_VERSION="${APP_VERSION#v}"
export PRODUCT_NAME="opentyrian"
export PROJECT_NAME="opentyrian"
export PORT_NAME="OpenTyrian"
export ICONSFILENAME="opentyrian"
export EXECUTABLE_NAME="opentyrian"
export PKGINFO="APPLTYR"

# constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data"

# The freeware Tyrian 2.1 data, bundled in Contents/Resources/data -- upstream
# looks there itself (SDL_GetBasePath() + "data")
./get_data.sh data || exit 1

# Universal build. CFLAGS replaces the Makefile's defaults, so repeat them.
ARCH_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=${MINIMUM_SYSTEM_VERSION}"
make clean
make -j$NCPU \
	PKG_CONFIG=/usr/local/bin/pkg-config \
	WITH_NETWORK=true \
	CFLAGS="-pedantic -Wall -Wextra -Wno-missing-field-initializers -O2 ${ARCH_FLAGS}" \
	LDFLAGS="${ARCH_FLAGS}" || exit 1
mv ${EXECUTABLE_NAME} "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
"../MSPBuildSystem/common/copy_dependencies.sh" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
cp -a "data/." "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data"

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
