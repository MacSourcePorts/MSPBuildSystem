# game/app specific values
export APP_VERSION="1.0"
export ICONSFILENAME="systemshock"
export PRODUCT_NAME="Shockolate"
export PROJECT_NAME="systemshock"
export PORT_NAME="Shockolate"
export EXECUTABLE_NAME="systemshock"
export PKGINFO="APPLESS1"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

rm -rf ${BUILT_PRODUCTS_DIR}

# build x86_64 fluidsynth
cd build_ext/fluidsynth-lite
#for the first one we can just delete the whole lib dir
rm -rf lib
mkdir -p lib/x86_64
cd lib/x86_64
cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=x86_64 ../..
cmake --build .
cp -a src/libfluidsynth* ../../src
cp -a include/fluidsynth/version.h ../../include/fluidsynth
cd ../../../../

# create x86_64 makefiles with cmake
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCMAKE_C_FLAGS="-DSDL_DISABLE_IMMINTRIN_H -DGL_SILENCE_DEPRECATION" \
    -DCMAKE_CXX_FLAGS="-DSDL_DISABLE_IMMINTRIN_H -DGL_SILENCE_DEPRECATION" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
    -DENABLE_SDL2=ON \
    -DENABLE_SOUND=ON \
    -DSDL2_DIR=/usr/local/opt/sdl2/lib/cmake/SDL2 \
    -DSDL2_MIXER_LIBRARIES=/usr/local/lib/libSDL2_mixer.dylib \
    -DENABLE_FLUIDSYNTH="BUNDLED" \
    -B. -S..

# perform x86_64 build with make
cd ${X86_64_BUILD_FOLDER}
make -j$NCPU

#tweak x86_64 install name
cd ..
install_name_tool -change $PWD/build_ext/fluidsynth-lite/src/libfluidsynth.1.dylib $PWD/build_ext/fluidsynth-lite/lib/x86_64/libfluidsynth.1.dylib ${X86_64_BUILD_FOLDER}/${EXECUTABLE_NAME}

mkdir -p ${X86_64_BUILD_FOLDER}/${WRAPPER_NAME}
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/res
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/shaders
mkdir -p ${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_NAME} ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cp ${ICONSDIR}/${ICONS} "${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}"
cp windows.sf2 ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/res
cp -a shaders/. ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/shaders

# build arm64 fluidsynth
cd build_ext/fluidsynth-lite
mkdir -p lib/arm64
cd lib/arm64
/usr/local/bin/cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_C_FLAGS_RELEASE="-arch arm64" ../..
/usr/local/bin/cmake --build .
cp -a src/libfluidsynth* ../../src
cp -a include/fluidsynth/version.h ../../include/fluidsynth
cd ../../../../

# create arm64 makefiles with cmake
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_C_FLAGS="-DSDL_DISABLE_IMMINTRIN_H -DGL_SILENCE_DEPRECATION" \
    -DCMAKE_CXX_FLAGS="-DSDL_DISABLE_IMMINTRIN_H -DGL_SILENCE_DEPRECATION" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
    -DENABLE_SDL2=ON \
    -DENABLE_SOUND=ON \
    -DSDL2_DIR=/opt/homebrew/opt/sdl2/lib/cmake/SDL2 \
    -DSDL2_MIXER_LIBRARIES=/opt/homebrew/lib/libSDL2_mixer.dylib \
    -DENABLE_FLUIDSYNTH="BUNDLED" \
     -B. -S..

# perform arm64 build with make
cd ${ARM64_BUILD_FOLDER}
make -j$NCPU

#tweak arm64 install name
cd ..
install_name_tool -change $PWD/build_ext/fluidsynth-lite/src/libfluidsynth.1.dylib $PWD/build_ext/fluidsynth-lite/lib/arm64/libfluidsynth.1.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_NAME}

mkdir -p ${ARM64_BUILD_FOLDER}/${WRAPPER_NAME}
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/res
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/shaders
mkdir -p ${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_NAME} ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cp ${ICONSDIR}/${ICONS} "${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}"
cp windows.sf2 ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/res
cp -a shaders/. ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/shaders

# making two app bundles, one for software-only mode, another for software and OpenGL
# the only difference is the software-only mode does not have the "shaders" directory
# doing this because at this time I'm experiencing an issue on Apple Silicon with the OpenGL modes

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/res
cp windows.sf2 ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/res

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"

mv "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}/${PRODUCT_NAME}-${APP_VERSION}.dmg" "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}/${PRODUCT_NAME}-${APP_VERSION}_softwaremode.dmg"
mv "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}/${PRODUCT_NAME}.app" "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}/${PRODUCT_NAME}_softwaremode.app"
echo rm -rf ${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}-${APP_VERSION}.dmg
rm -rf ${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}-${APP_VERSION}.dmg

#now copy the shaders to the bundle
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/shaders
cp -a shaders/. ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/shaders

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipdelete"