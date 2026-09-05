# game/app specific values
export APP_VERSION="1.1.0"
export PRODUCT_NAME="circuslinux"
export PROJECT_NAME="circuslinux"
export PORT_NAME="circuslinux"
export ICONSFILENAME="circuslinux"
export EXECUTABLE_NAME="circuslinux"
export PKGINFO="APPLNBS7"

# constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}

make clean
(ARCH="arm64 -arch x86_64" SDL_CFLAGS="-I/usr/local/include/SDL -D_GNU_SOURCE=1 -D_THREAD_SAFE -mmacosx-version-min=10.7" SDL_LDFLAGS="-L/usr/local/lib -lSDLmain -lSDL -Wl,-framework,Cocoa -mmacosx-version-min=10.7" make -j$NCPU)
mkdir -p ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}"
cp "${EXECUTABLE_NAME}" ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}"
mkdir -p ${BUILT_PRODUCTS_DIR}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/Data
cp -a Data/* ${BUILT_PRODUCTS_DIR}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/Data
"../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# copy over sdl2 manually as shim for sdl12-compat
cp /usr/local/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"

# sign and notarize (with entitlements)
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"