# game/app specific values
export APP_VERSION="0.2.5"
export PRODUCT_NAME="madbomber"
export PROJECT_NAME="madbomber"
export PORT_NAME="madbomber"
export ICONSFILENAME="madbomber"
export EXECUTABLE_NAME="madbomber"
export PKGINFO="APPLNBS4"

# constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	rm -rf ${BUILT_PRODUCTS_DIR}
	mkdir ${BUILT_PRODUCTS_DIR}

    make clean
    (ARCH="arm64 -arch x86_64" SDL_CFLAGS="-I/usr/local/include/SDL -D_GNU_SOURCE=1 -D_THREAD_SAFE -mmacosx-version-min=10.7" SDL_LDFLAGS="-L/usr/local/lib -lSDLmain -lSDL -Wl,-framework,Cocoa -mmacosx-version-min=10.7" make -j$NCPU)
    mkdir -p ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}"
    cp "${EXECUTABLE_NAME}" ${BUILT_PRODUCTS_DIR}/"${EXECUTABLE_FOLDER_PATH}"
    mkdir -p ${BUILT_PRODUCTS_DIR}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/Data
    cp -a Data/* ${BUILT_PRODUCTS_DIR}/"${UNLOCALIZED_RESOURCES_FOLDER_PATH}"/Data
    install_name_tool -add_rpath @executable_path/. ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    "../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
else
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
fi

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

    # copy over sdl2 manually as shim for sdl12-compat
    cp /usr/local/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
else
    "../MSPBuildSystem/common/build_app_bundle.sh"

    # copy over sdl2 manually as shim for sdl12-compat
    cp /usr/local/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}"
    cp /opt/homebrew/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}"
fi

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"