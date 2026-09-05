# game/app specific values
export APP_VERSION="0.7.8"
export ICONSFILENAME="systemshock"
export PRODUCT_NAME="Shockolate"
export PROJECT_NAME="systemshock"
export PORT_NAME="Shockolate"
export EXECUTABLE_NAME="systemshock"
export PKGINFO="APPLESS1"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.9"

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake
mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
cmake \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_C_FLAGS="-DSDL_DISABLE_IMMINTRIN_H -DGL_SILENCE_DEPRECATION" \
    -DCMAKE_CXX_FLAGS="-DSDL_DISABLE_IMMINTRIN_H -DGL_SILENCE_DEPRECATION" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
    -DENABLE_SDL2=ON \
    -DENABLE_SOUND=ON \
    -DSDL2_DIR=/usr/local/opt/sdl2/lib/cmake/SDL2 \
    -DSDL2_MIXER_LIBRARIES=/usr/local/lib/libSDL2_mixer.dylib \
    -DENABLE_FLUIDSYNTH="BUNDLED" \
    -DFLUIDSYNTH_LIBRARY=/usr/local/lib/libfluidsynth.1.dylib \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -B. -S..

cmake --build . --parallel $NCPU

#tweak install name
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
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"