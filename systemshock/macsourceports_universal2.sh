# game/app specific values
# Built from the latest upstream code. Upstream's last tag (v0.8.2) is old, so
# it's only the base of the version; a dated build (MSP_VERSION_DATE) makes it
# e.g. 0.8.2-20261114. The --match skips old fork tags like v0.78_2025-07-12
# and upstream's own early v.0.5.x tags. Set before constants.sh so it gets dated.
APP_VERSION=`git -C ../../systemshock describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*'`
export APP_VERSION="${APP_VERSION#v}"
export ICONSFILENAME="systemshock"
export PRODUCT_NAME="Shockolate"
export PROJECT_NAME="systemshock"
export PORT_NAME="Shockolate"
export EXECUTABLE_NAME="systemshock"
export PKGINFO="APPLESS1"

# constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.9"

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake
mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
# Use the FluidSynth 2.x in /usr/local (found via pkg-config), like SDL2 and SDL2_mixer.
# Upstream's BUNDLED option now downloads fluidsynth-lite, which fakes clock_gettime
# for targets before 10.12 and so fails to build against the current SDK at 10.9.
cmake \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_C_FLAGS="-DSDL_DISABLE_IMMINTRIN_H -DGL_SILENCE_DEPRECATION" \
    -DCMAKE_CXX_FLAGS="-DSDL_DISABLE_IMMINTRIN_H -DGL_SILENCE_DEPRECATION" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
    -DENABLE_SDL2=ON \
    -DENABLE_SOUND=ON \
    -DSDL2_DIR=/usr/local/opt/sdl2/lib/cmake/SDL2 \
    -DSDL2_MIXER_LIBRARIES=/usr/local/lib/libSDL2_mixer.dylib \
    -DENABLE_FLUIDSYNTH=ON \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -B. -S..

cmake --build . --parallel $NCPU

# tweak install name
cd ..
# install_name_tool -change /usr/local/lib64/libfluidsynth.1.dylib @rpath/libfluidsynth.1.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_NAME}

mkdir -p ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
mkdir -p ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/res
mkdir -p ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/shaders
echo mv ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
mv ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
"../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
cp ${ICONSDIR}/${ICONS} "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}"
cp ../MSPBuildSystem/systemshock/windows.sf2 ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/res
cp -a shaders/. ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/shaders

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"