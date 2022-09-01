# game/app specific values
export APP_VERSION="0.9.18"
export PRODUCT_NAME="fheroes2"
export PROJECT_NAME="fheroes2"
export PORT_NAME="fheroes2"
export ICONSFILENAME="fheroes2"
export EXECUTABLE_NAME="fheroes2"
export PKGINFO="APPLFH2"
export GIT_TAG="0.9.18"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh
source ../common/signing_values.local

cd ../../${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

# check out the latest release tag
echo git checkout tags/${GIT_TAG}
git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake, perform builds with make
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd ${X86_64_BUILD_FOLDER}
cmake \
-DMACOS_APP_BUNDLE=ON \
-DCMAKE_OSX_ARCHITECTURES=x86_64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
..
make -j$NCPU

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd ${ARM64_BUILD_FOLDER}
cmake  \
-DMACOS_APP_BUNDLE=ON \
-DCMAKE_OSX_ARCHITECTURES=arm64 \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/opt/Homebrew \
-DCMAKE_INSTALL_PREFIX=/opt/Homebrew \
..
make -j$NCPU

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

#create any app-specific directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs" || exit 1;
fi

#lipo any app-specific things
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libjpeg.8.2.2.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libjpeg.8.2.2.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libjpeg.8.2.2.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libmodplug.1.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libmodplug.1.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmodplug.1.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libmpg123.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libmpg123.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmpg123.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libpng16.16.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libpng16.16.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libpng16.16.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_image-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_image-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_image-2.0.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_mixer-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_mixer-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_mixer-2.0.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2-2.0.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libtiff.5.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libtiff.5.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libtiff.5.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libwebp.7.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libwebp.7.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libwebp.7.dylib" -create

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libjpeg.8.2.2.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmodplug.1.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmpg123.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libpng16.16.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_image-2.0.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_mixer-2.0.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2-2.0.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libtiff.5.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libwebp.7.dylib

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"