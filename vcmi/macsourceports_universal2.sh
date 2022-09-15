# game/app specific values
export APP_VERSION="0.9.18"
export PRODUCT_NAME="vcmi"
export PROJECT_NAME="vcmi"
export PORT_NAME="vcmi"
export ICONSFILENAME="vcmi"
export EXECUTABLE_NAME="vcmilauncher"
export PKGINFO="APPLVCMI"
export GIT_TAG="0.9.18"
export GIT_DEFAULT_BRANCH="develop"

export ORIGINAL_PATH=$PATH

#constants
source ../common/constants.sh
source ../common/signing_values.local

cd ../../${PROJECT_NAME}

# reset to the main branch
# echo git checkout ${GIT_DEFAULT_BRANCH}
# git checkout ${GIT_DEFAULT_BRANCH}

# # fetch the latest 
# echo git pull
# git pull

# # check out the latest release tag
# echo git checkout tags/${GIT_TAG}
# git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}

# export PATH=/usr/local/opt/qt5:/usr/local/opt/qt5/bin:${ORIGINAL_PATH}
# echo "PATH: " $PATH

# # create makefiles with cmake, perform builds with make
# rm -rf ${X86_64_BUILD_FOLDER}
# mkdir ${X86_64_BUILD_FOLDER}
# mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd ${X86_64_BUILD_FOLDER}
# cmake \
# -DMACOS_APP_BUNDLE=ON \
# -DCMAKE_OSX_ARCHITECTURES=x86_64 \
# -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
# -DCMAKE_PREFIX_PATH=/usr/local \
# -DCMAKE_INSTALL_PREFIX=/usr/local \
# ..
# make -j$NCPU
cp -a bin/* ${EXECUTABLE_FOLDER_PATH}

# export PATH=/opt/Homebrew/opt/qt5:/opt/Homebrew/opt/qt5/bin:$ORIGINAL_PATH
# echo "PATH: " $PATH

cd ..
# rm -rf ${ARM64_BUILD_FOLDER}
# mkdir ${ARM64_BUILD_FOLDER}
# mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd ${ARM64_BUILD_FOLDER}
# cmake  \
# -DMACOS_APP_BUNDLE=ON \
# -DCMAKE_OSX_ARCHITECTURES=arm64 \
# -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
# -DCMAKE_PREFIX_PATH=/opt/Homebrew \
# -DCMAKE_INSTALL_PREFIX=/opt/Homebrew \
# ..
# make -j$NCPU
cp -a bin/* ${EXECUTABLE_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

# dylibbundle the other executables
cd ${X86_64_BUILD_FOLDER}
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/vcmiclient" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/vcmiserver" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/vcmitest" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
install_name_tool -change @rpath/libvcmi.dylib @executable_path/${X86_64_LIBS_FOLDER}/libvcmi.dylib ${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiLua.dylib
install_name_tool -change @rpath/libminizip.dylib @executable_path/${X86_64_LIBS_FOLDER}/libminizip.dylib ${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiLua.dylib
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiLua.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
install_name_tool -change @rpath/libvcmi.dylib @executable_path/${X86_64_LIBS_FOLDER}/libvcmi.dylib ${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiERM.dylib
install_name_tool -change @rpath/libminizip.dylib @executable_path/${X86_64_LIBS_FOLDER}/libminizip.dylib ${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiERM.dylib
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiERM.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
install_name_tool -change @rpath/libvcmi.dylib @executable_path/${X86_64_LIBS_FOLDER}/libvcmi.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libBattleAI.dylib
install_name_tool -change @rpath/libminizip.dylib @executable_path/${X86_64_LIBS_FOLDER}/libminizip.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libBattleAI.dylib
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/AI/libBattleAI.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
install_name_tool -change @rpath/libvcmi.dylib @executable_path/${X86_64_LIBS_FOLDER}/libvcmi.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libVCAI.dylib
install_name_tool -change @rpath/libminizip.dylib @executable_path/${X86_64_LIBS_FOLDER}/libminizip.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libVCAI.dylib
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/AI/libVCAI.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
install_name_tool -change @rpath/libvcmi.dylib @executable_path/${X86_64_LIBS_FOLDER}/libvcmi.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libStupidAI.dylib
install_name_tool -change @rpath/libminizip.dylib @executable_path/${X86_64_LIBS_FOLDER}/libminizip.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libStupidAI.dylib
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/AI/libStupidAI.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
install_name_tool -change @rpath/libvcmi.dylib @executable_path/${X86_64_LIBS_FOLDER}/libvcmi.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libEmptyAI.dylib
install_name_tool -change @rpath/libminizip.dylib @executable_path/${X86_64_LIBS_FOLDER}/libminizip.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libEmptyAI.dylib
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/AI/libEmptyAI.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
install_name_tool -change @rpath/libvcmi.dylib @executable_path/${X86_64_LIBS_FOLDER}/libvcmi.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libNullkiller.dylib
install_name_tool -change @rpath/libminizip.dylib @executable_path/${X86_64_LIBS_FOLDER}/libminizip.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libNullkiller.dylib
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/AI/libNullkiller.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/

cd ..
cp -a ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}

cd ${ARM64_BUILD_FOLDER}
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/vcmiclient" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/vcmiserver" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/vcmitest" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
install_name_tool -change @rpath/libvcmi.dylib @executable_path/${ARM64_LIBS_FOLDER}/libvcmi.dylib ${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiLua.dylib
install_name_tool -change @rpath/libminizip.dylib @executable_path/${ARM64_LIBS_FOLDER}/libminizip.dylib ${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiLua.dylib
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiLua.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
install_name_tool -change @rpath/libvcmi.dylib @executable_path/${ARM64_LIBS_FOLDER}/libvcmi.dylib ${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiERM.dylib
install_name_tool -change @rpath/libminizip.dylib @executable_path/${ARM64_LIBS_FOLDER}/libminizip.dylib ${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiERM.dylib
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiERM.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
install_name_tool -change @rpath/libvcmi.dylib @executable_path/${ARM64_LIBS_FOLDER}/libvcmi.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libBattleAI.dylib
install_name_tool -change @rpath/libminizip.dylib @executable_path/${ARM64_LIBS_FOLDER}/libminizip.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libBattleAI.dylib
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/AI/libBattleAI.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
install_name_tool -change @rpath/libvcmi.dylib @executable_path/${ARM64_LIBS_FOLDER}/libvcmi.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libVCAI.dylib
install_name_tool -change @rpath/libminizip.dylib @executable_path/${ARM64_LIBS_FOLDER}/libminizip.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libVCAI.dylib
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/AI/libVCAI.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
install_name_tool -change @rpath/libvcmi.dylib @executable_path/${ARM64_LIBS_FOLDER}/libvcmi.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libStupidAI.dylib
install_name_tool -change @rpath/libminizip.dylib @executable_path/${ARM64_LIBS_FOLDER}/libminizip.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libStupidAI.dylib
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/AI/libStupidAI.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
install_name_tool -change @rpath/libvcmi.dylib @executable_path/${ARM64_LIBS_FOLDER}/libvcmi.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libEmptyAI.dylib
install_name_tool -change @rpath/libminizip.dylib @executable_path/${ARM64_LIBS_FOLDER}/libminizip.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libEmptyAI.dylib
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/AI/libEmptyAI.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
install_name_tool -change @rpath/libvcmi.dylib @executable_path/${ARM64_LIBS_FOLDER}/libvcmi.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libNullkiller.dylib
install_name_tool -change @rpath/libminizip.dylib @executable_path/${ARM64_LIBS_FOLDER}/libminizip.dylib ${EXECUTABLE_FOLDER_PATH}/AI/libNullkiller.dylib
dylibbundler -cd -of -b -x "./${EXECUTABLE_FOLDER_PATH}/AI/libNullkiller.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/

cd ..
cp -a ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}

#create any app-specific directories
mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/launcher" || exit 1;
mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/test" || exit 1;
mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/config" || exit 1;
mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/Mods" || exit 1;
mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/scripting" || exit 1;
mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/AI" || exit 1;

#copy over anything non-executable we need
echo cp -a ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/launcher/* "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/launcher"
cp -a ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/launcher/* "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/launcher"
cp -a ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/test/* "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/test"
cp -a ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/config/* "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/config"
cp -a ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/Mods/* "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/Mods"

#lipo any app-specific things
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiLua.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiLua.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiLua.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiERM.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiERM.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/scripting/libvcmiERM.dylib" -create

lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/AI/libBattleAI.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/AI/libBattleAI.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/AI/libBattleAI.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/AI/libVCAI.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/AI/libVCAI.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/AI/libVCAI.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/AI/libStupidAI.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/AI/libStupidAI.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/AI/libStupidAI.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/AI/libEmptyAI.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/AI/libEmptyAI.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/AI/libEmptyAI.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/AI/libNullkiller.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/AI/libNullkiller.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/AI/libNullkiller.dylib" -create

lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/vcmiserver ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/vcmiserver -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/vcmiserver" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/vcmitest ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/vcmitest -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/vcmitest" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/vcmilauncher ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/vcmilauncher -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/vcmilauncher" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/vcmiclient ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/vcmiclient -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/vcmiclient" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libminizip.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libminizip.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libminizip.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libvcmi.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libvcmi.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libvcmi.dylib" -create

# codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libjpeg.8.2.2.dylib
# codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmodplug.1.dylib
# codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmpg123.0.dylib
# codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libpng16.16.dylib
# codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_image-2.0.0.dylib
# codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_mixer-2.0.0.dylib
# codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2-2.0.0.dylib
# codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libtiff.5.dylib
# codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libwebp.7.dylib

#sign and notarize
# "../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
# "../MSPBuildSystem/common/package_dmg.sh"