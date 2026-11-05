# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="Akhenaten"
export PROJECT_NAME="Akhenaten"
export PORT_NAME="Akhenaten"
export ICONSFILENAME="akhenaten"
export EXECUTABLE_NAME="akhenaten"

# constants
source ../common/constants.sh

CROSS_FILE_DIR=$PWD

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}

gsed -i "s|v1.3.1|v1.3.2|" CMakeLists.txt

# OpenH264 is built with meson, which ignores CMAKE_OSX_ARCHITECTURES and always builds for the host.
# Let the x86_64 pass hand meson a cross file so libopenh264.a isn't arm64-only.
gsed -i 's|--backend=${_oh_backend}$|--backend=${_oh_backend} ${OPENH264_MESON_EXTRA_ARGS}|' cmake/BuildOpenH264.cmake

# Akhenaten builds its bundled SDL2/SDL2_mixer/freetype/harfbuzz/zlib in sub-builds, and a list-expansion bug
# in its CMakeLists drops CMAKE_OSX_DEPLOYMENT_TARGET on the way, so they target the host OS (e.g. 26.0).
# Sub-builds still pick up the deployment target from the environment.
export MACOSX_DEPLOYMENT_TARGET=10.15

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
cmake \
-DCMAKE_OSX_ARCHITECTURES="x86_64" \
-DOPENH264_MESON_EXTRA_ARGS="--cross-file=${CROSS_FILE_DIR}/openh264-x86_64-cross.txt" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
..
cmake --build . --parallel $NCPU

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
..
cmake --build . --parallel $NCPU

install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/build/build_arm64/lib/libssl.3.dylib  @rpath/libssl.3.dylib "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/build/build_arm64/lib/libcrypto.3.dylib  @rpath/libcrypto.3.dylib "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"