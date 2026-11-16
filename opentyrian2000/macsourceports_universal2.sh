# game/app specific values
# Built from KScl/opentyrian2000's latest release tag (v2000.20250408 -> 2000.20250408)
APP_VERSION=`git -C ../../opentyrian2000 describe --tags --abbrev=0 --match 'v2000.*'`
export APP_VERSION="${APP_VERSION#v}"
export PRODUCT_NAME="opentyrian2000"
export PROJECT_NAME="opentyrian2000"
export PORT_NAME="OpenTyrian2000"
export ICONSFILENAME="opentyrian2000"
export EXECUTABLE_NAME="opentyrian2000"
export PKGINFO="APPLTYR2K"

# constants
source ../common/constants.sh

CROSS_FILE_DIR=$PWD

cd ../../${PROJECT_NAME}

# Look for the game data inside the app bundle (Contents/Resources/data).
# Skip if it's already applied.
if ! git apply -R --check "${CROSS_FILE_DIR}/msp-bundle-data.patch" 2>/dev/null; then
	git apply "${CROSS_FILE_DIR}/msp-bundle-data.patch" || exit 1
fi

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/data"

# The freeware Tyrian 2000 data (the zip upstream's README points at), with
# lowercase filenames, which is what the engine opens -- the same way upstream
# opentyrian's get_data.sh does it for Tyrian 2.1
if [ ! -f data/tyrian1.lvl ]; then
	DATA_TMP=$(mktemp -d)
	curl -fL -o "${DATA_TMP}/tyrian2000.zip" https://www.camanis.net/tyrian/tyrian2000.zip || exit 1
	unzip -q -o "${DATA_TMP}/tyrian2000.zip" -d "${DATA_TMP}/x" || exit 1
	DATA_SRC=$(dirname "$(find "${DATA_TMP}/x" -iname tyrian1.lvl | head -1)")
	mkdir -p data
	for f in "${DATA_SRC}"/*; do
		[ -f "$f" ] && cp "$f" "data/$(basename "$f" | tr '[:upper:]' '[:lower:]')"
	done
	rm -rf "${DATA_TMP}"
	[ -f data/tyrian1.lvl ] || { echo "ERROR: no Tyrian 2000 data"; exit 1; }
fi

# Universal build. CFLAGS replaces the Makefile's defaults, so repeat them.
ARCH_FLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=${MINIMUM_SYSTEM_VERSION}"
make clean
make -j$NCPU \
	PKG_CONFIG=/usr/local/bin/pkg-config \
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
