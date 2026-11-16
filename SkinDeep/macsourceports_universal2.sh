# game/app specific values
# Built from the latest code on the macos branch of the MacSourcePorts fork
# (https://github.com/MacSourcePorts/SkinDeep, forked from m0rb/SkinDeep, which
# is blendogames/SkinDeep plus Linux/FreeBSD support). Neither upstream makes
# releases, so the version is the game's own (ENGINE_VERSION "Skin Deep 1.0"
# plus BUILD_NUMBER, e.g. 1.0.4) and a dated build (MSP_VERSION_DATE) makes it
# e.g. 1.0.4-20261115. Set before constants.sh so it gets dated.
BUILD_NUMBER=`sed -n 's/^const int BUILD_NUMBER = \([0-9]*\);.*/\1/p' ../../SkinDeep/framework/BuildVersion.h`
export APP_VERSION="1.0.${BUILD_NUMBER}"
export PRODUCT_NAME="SkinDeep"
export PROJECT_NAME="SkinDeep"
export PORT_NAME="Skin Deep"
export ICONSFILENAME="skindeep"
export EXECUTABLE_NAME="SkinDeep"
export PKGINFO="APPLSKDP"

# constants
source ../common/constants.sh
# the code uses std::format, which needs the macOS 13.3 runtime
export MINIMUM_SYSTEM_VERSION="13.3"

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
# DHEWM3BINARY names the executable and the .app bundle CMake creates.
# OpenAL Soft rather than Apple's OpenAL.framework: the game wants EFX.
cmake -G "Unix Makefiles" "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION} -DSDL2=ON -DDHEWM3BINARY=${EXECUTABLE_NAME} -DOPENAL_LIBRARY=/usr/local/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/usr/local/include .. -Wno-dev
cmake --build . --parallel $NCPU
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

# CMake copies dhewm3's Doom 3 icon and resource fork into the bundle
rm -f "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Doom3.icns" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Doom 3.rsrc"

# the game library is loaded from next to the executable
cp ${BUILT_PRODUCTS_DIR}/d3xp.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/"

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
