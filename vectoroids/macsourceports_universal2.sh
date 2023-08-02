# game/app specific values
export APP_VERSION="1.1.0"
export PRODUCT_NAME="vectoroids"
export PROJECT_NAME="vectoroids"
export PORT_NAME="vectoroids"
export ICONSFILENAME="vectoroids"
export EXECUTABLE_NAME="vectoroids"
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
(ARCH=x86_64 SDL_CFLAGS="-I/usr/local/include/SDL -D_GNU_SOURCE=1 -D_THREAD_SAFE -mmacosx-version-min=10.9" SDL_LDFLAGS="-L/usr/local/lib -lSDLmain -lSDL -Wl,-framework,Cocoa -mmacosx-version-min=10.9" make -j$NCPU)
mkdir -p ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
cp "${EXECUTABLE_NAME}" ${X86_64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
mkdir -p ${X86_64_BUILD_FOLDER}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/Data
cp -a Data/* ${X86_64_BUILD_FOLDER}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/Data

make clean
(ARCH=arm64 SDL_CFLAGS="-I/opt/homebrew/include/SDL -D_GNU_SOURCE=1 -D_THREAD_SAFE -mmacosx-version-min=10.9" SDL_LDFLAGS="-L/opt/homebrew/lib -lSDLmain -lSDL -Wl,-framework,Cocoa -mmacosx-version-min=10.9" make -j$NCPU)
mkdir -p ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
cp "${EXECUTABLE_NAME}" ${ARM64_BUILD_FOLDER}/"${EXECUTABLE_FOLDER_PATH}"
mkdir -p ${ARM64_BUILD_FOLDER}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/Data
cp -a Data/* ${ARM64_BUILD_FOLDER}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/Data

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

# copy over sdl2 manually as shim for sdl12-compat
cp /usr/local/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}"
cp /opt/homebrew/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}"

# sign and notarize (with entitlements)
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"