# game/app specific values
export APP_VERSION="1.0.6"
export PRODUCT_NAME="fheroes2"
export PROJECT_NAME="fheroes2"
export PORT_NAME="fheroes2"
export ICONSFILENAME="fheroes2"
export EXECUTABLE_NAME="fheroes2"
export PKGINFO="APPLFH2"
export GIT_TAG="1.0.6"
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
# lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libmodplug.1.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libmodplug.1.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmodplug.1.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libmpg123.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libmpg123.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmpg123.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libpng16.16.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libpng16.16.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libpng16.16.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_image-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_image-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_image-2.0.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_mixer-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_mixer-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_mixer-2.0.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2-2.0.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libtiff.6.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libtiff.6.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libtiff.6.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libwebp.7.1.7.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libwebp.7.1.7.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libwebp.7.1.7.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libxmp.4.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libxmp.4.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libxmp.4.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libjxl.0.8.2.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libjxl.0.8.2.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libjxl.0.8.2.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libFLAC.12.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libFLAC.12.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libFLAC.12.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libaom.3.6.1.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libaom.3.6.1.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libaom.3.6.1.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libavif.15.0.1.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libavif.15.0.1.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libavif.15.0.1.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libbrotlicommon.1.0.9.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libbrotlicommon.1.0.9.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libbrotlicommon.1.0.9.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libbrotlidec.1.0.9.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libbrotlidec.1.0.9.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libbrotlidec.1.0.9.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libbrotlienc.1.0.9.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libbrotlienc.1.0.9.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libbrotlienc.1.0.9.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libfluidsynth.3.2.1.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libfluidsynth.3.2.1.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libfluidsynth.3.2.1.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libglib-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libglib-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libglib-2.0.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libgthread-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libgthread-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libgthread-2.0.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libhwy.1.0.5.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libhwy.1.0.5.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libhwy.1.0.5.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libintl.8.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libintl.8.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libintl.8.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/liblcms2.2.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/liblcms2.2.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/liblcms2.2.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/liblzma.5.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/liblzma.5.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/liblzma.5.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libmp3lame.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libmp3lame.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmp3lame.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libogg.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libogg.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libogg.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libopus.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libopus.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libopus.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libopusfile.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libopusfile.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libopusfile.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libpcre2-8.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libpcre2-8.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libpcre2-8.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libportaudio.2.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libportaudio.2.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libportaudio.2.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libreadline.8.2.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libreadline.8.2.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libreadline.8.2.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libsharpyuv.0.0.1.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libsharpyuv.0.0.1.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libsharpyuv.0.0.1.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libsndfile.1.0.35.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libsndfile.1.0.35.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libsndfile.1.0.35.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libvmaf.1.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libvmaf.1.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libvmaf.1.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libvorbis.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libvorbis.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libvorbis.0.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libvorbisenc.2.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libvorbisenc.2.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libvorbisenc.2.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libvorbisfile.3.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libvorbisfile.3.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libvorbisfile.3.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libzstd.1.5.5.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libzstd.1.5.5.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libzstd.1.5.5.dylib" -create

codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libjpeg.8.2.2.dylib
# codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmodplug.1.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmpg123.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libpng16.16.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_image-2.0.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_mixer-2.0.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2-2.0.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libtiff.6.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libwebp.7.1.7.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libxmp.4.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libjxl.0.8.2.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libFLAC.12.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libaom.3.6.1.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libavif.15.0.1.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libbrotlicommon.1.0.9.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libbrotlidec.1.0.9.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libbrotlienc.1.0.9.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libfluidsynth.3.2.1.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libglib-2.0.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libgthread-2.0.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libhwy.1.0.5.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libintl.8.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/liblcms2.2.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/liblzma.5.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmp3lame.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libogg.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libopus.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libopusfile.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libpcre2-8.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libportaudio.2.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libreadline.8.2.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libsharpyuv.0.0.1.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libsndfile.1.0.35.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libvmaf.1.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libvorbis.0.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libvorbisenc.2.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libvorbisfile.3.dylib
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libzstd.1.5.5.dylib

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"