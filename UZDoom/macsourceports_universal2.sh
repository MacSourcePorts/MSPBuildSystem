# game/app specific values
export APP_VERSION="4.14.3"
export PRODUCT_NAME="UZDoom"
export PROJECT_NAME="UZDoom"
export PORT_NAME="UZDoom"
export ICONSFILENAME="UZDoom"
export EXECUTABLE_NAME="uzdoom"
export PKGINFO="APPLUZDM"
export ENTITLEMENTS_FILE="../MSPBuildSystem/UZDoom/UZDoom.entitlements"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.13"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

gsed -i '/if( ${TARGET_ARCHITECTURE} MATCHES "x86_64" )/,/endif()/d' CMakeLists.txt
gsed -i '/if( ${TARGET_ARCHITECTURE} MATCHES "x86_64" )/,/endif()/d' src/CMakeLists.txt
gsed -i '/if ( ${TARGET_ARCHITECTURE} MATCHES "arm64" )/,/endif()/d' src/CMakeLists.txt
gsed -i '/if (NOT ${TARGET_ARCHITECTURE} MATCHES "arm" )/,/endif()/d' src/CMakeLists.txt
gsed -i '/if (MSVC AND ${TARGET_ARCHITECTURE} MATCHES "arm")/,/endif()/d' src/CMakeLists.txt

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}

cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13 \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DOPENAL_INCLUDE_DIR=/usr/local/include/AL \
  -DOPENAL_LIBRARY=/usr/local/lib/libopenal.dylib \
  -DVPX_INCLUDE_DIR=/usr/local/include \
  -DVPX_LIBRARIES=/usr/local/lib/libvpx.a \
  -DDYN_OPENAL=OFF \
  -DHAVE_VULKAN=ON \
  -DHAVE_GLES2=OFF \
  -G Ninja \
  ..
cmake --build . --parallel $NCPU

"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

cd ..

gsed -i "s|org.zdoom.UZDoom|com.macsourceports.UZDoom|" "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"
gsed -i "s|Development Version|${APP_VERSION}|" "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"
gsed -i "s|zdoom.icns|UZDoom.icns|" "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

echo rm "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/zdoom.icns";
rm "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/zdoom.icns";
echo cp "${ICONSDIR}/${ICONS}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}" || exit 1;
cp "${ICONSDIR}/${ICONS}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}" || exit 1;

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"