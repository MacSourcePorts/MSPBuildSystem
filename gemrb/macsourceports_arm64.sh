# game/app specific values
export APP_VERSION="0.9.3"
export PRODUCT_NAME="gemrb"
export PROJECT_NAME="gemrb"
export PORT_NAME="GemRB"
export ICONSFILENAME="gemrb"
export EXECUTABLE_NAME="gemrb"
export PKGINFO="APPLGRB"
export GIT_TAG="v0.9.3"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

export ENTITLEMENTS_FILE="../MSPBuildSystem/gemrb/gemrb.entitlements"
export HIGH_RESOLUTION_CAPABLE="true"
export PRODUCT_BUNDLE_IDENTIFIER="org.gemrb.gemrb"
export ARCH_FOLDER="/arm64"
export ARCH_SUFFIX="-arm64"

cd ../../${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake, perform builds with make
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake  \
-DDISABLE_WERROR=1  \
-DCMAKE_OSX_ARCHITECTURES=arm64  \
-DCMAKE_BUILD_TYPE=Release  \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.12  \
-DCMAKE_PREFIX_PATH=/opt/Homebrew  \
-DCMAKE_INSTALL_PREFIX=/opt/Homebrew  \
-DPYTHON_LIBRARIES=/opt/Homebrew/Frameworks/Python.framework/Versions/3.9/lib/libpython3.9.dylib  \
-DPYTHON_INCLUDE_DIRS=/opt/Homebrew/Frameworks/Python.framework/Versions/3.9/include/python3.9  \
-DLIBVLC_INCLUDE_DIR=/Applications/VLC.app/Contents/MacOS/include \
-DLIBVLC_LIBRARY=/Applications/VLC.app/Contents/MacOS/lib/libvlc.dylib \
..
make
install_name_tool -add_rpath @executable_path/../Frameworks/. gemrb/${PRODUCT_NAME}.app/Contents/MacOS/gemrb
mv gemrb/${PRODUCT_NAME}.app ../release

cd ..

source ../MSPBuildSystem/common/signing_values.local

cp -a /opt/homebrew/opt/python@3.9/Frameworks/Python.framework release/gemrb.app/Contents/Frameworks
echo codesign --force --timestamp --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9
codesign --force --timestamp --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9

install_name_tool -change /opt/homebrew/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/Python @executable_path/../Frameworks/Python.framework/Versions/3.9/Python release/gemrb.app/Contents/PlugIns/GUIScript.so

cp /opt/homebrew/opt/sdl2_mixer/lib/libSDL2_mixer-2.0.0.dylib release/gemrb.app/Contents/Frameworks
dylibbundler -od -b -x release/gemrb.app/Contents/Frameworks/libSDL2_mixer-2.0.0.dylib -d release/gemrb.app/Contents/MacOS/libs-arm64 -p @executable_path/libs-arm64/
install_name_tool -change /opt/homebrew/opt/sdl2_mixer/lib/libSDL2_mixer-2.0.0.dylib @executable_path/../Frameworks/libSDL2_mixer-2.0.0.dylib release/gemrb.app/Contents/PlugIns/SDLAudio.so

install_name_tool -change /opt/homebrew/opt/libvorbis/lib/libvorbisfile.3.dylib @executable_path/libs-arm64/libvorbisfile.3.dylib release/gemrb.app/Contents/PlugIns/OGGReader.so

cp /opt/homebrew/opt/libpng/lib/libpng16.16.dylib release/gemrb.app/Contents/MacOS/libs-arm64
install_name_tool -change /opt/homebrew/opt/libpng/lib/libpng16.16.dylib @executable_path/libs-arm64/libpng16.16.dylib release/gemrb.app/Contents/PlugIns/PNGImporter.so

cp /opt/homebrew/opt/freetype/lib/libfreetype.6.dylib release/gemrb.app/Contents/MacOS/libs-arm64
install_name_tool -change /opt/homebrew/opt/freetype/lib/libfreetype.6.dylib @executable_path/libs-arm64/libfreetype.6.dylib release/gemrb.app/Contents/PlugIns/TTFImporter.so
install_name_tool -change /opt/homebrew/opt/libpng/lib/libpng16.16.dylib @executable_path/libs-arm64/libpng16.16.dylib release/gemrb.app/Contents/MacOS/libs-arm64/libfreetype.6.dylib

find release/gemrb.app/Contents/Frameworks/Python.framework -type f -name "*.so" -exec echo codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" {} \;
find release/gemrb.app/Contents/Frameworks/Python.framework -type f -name "*.so" -exec codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" {} \;

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"