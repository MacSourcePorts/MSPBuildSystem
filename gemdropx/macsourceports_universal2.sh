# game/app specific values
export APP_VERSION="0.9"
export PRODUCT_NAME="gemdropx"
export PROJECT_NAME="gemdropx"
export PORT_NAME="gemdropx"
export ICONSFILENAME="gemdropx"
export EXECUTABLE_NAME="gemdropx"
export PKGINFO="APPLNBS4"

# constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

make clean
(ARCH=x86_64 SDL_CFLAGS="-I/usr/local/include/SDL -D_GNU_SOURCE=1 -D_THREAD_SAFE" SDL_LDFLAGS="-L/usr/local/lib -lSDLmain -lSDL -Wl,-framework,Cocoa" make -j$NCPU)
mkdir -p ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
cp "${EXECUTABLE_NAME}" ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
mkdir -p ${X86_64_BUILD_FOLDER}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/Data
cp -a Data/* ${X86_64_BUILD_FOLDER}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/Data

make clean
(ARCH=arm64 SDL_CFLAGS="-I/opt/homebrew/include/SDL -D_GNU_SOURCE=1 -D_THREAD_SAFE" SDL_LDFLAGS="-L/opt/homebrew/lib -lSDLmain -lSDL -Wl,-framework,Cocoa" make -j$NCPU)
mkdir -p ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
cp "${EXECUTABLE_NAME}" ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
mkdir -p ${ARM64_BUILD_FOLDER}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/Data
cp -a Data/* ${ARM64_BUILD_FOLDER}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/Data

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

# sign and notarize (with entitlements)
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"