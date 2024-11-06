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
export PYTHON_VERSION=3.12

#constants
source ../common/constants.sh

export ENTITLEMENTS_FILE="../MSPBuildSystem/gemrb/gemrb.entitlements"
export HIGH_RESOLUTION_CAPABLE="true"
export PRODUCT_BUNDLE_IDENTIFIER="org.gemrb.gemrb"
export ARCH_FOLDER="/arm64"
export ARCH_SUFFIX="-arm64"

cd ../../${PROJECT_NAME}

if [ -n "$3" ]; then
	export APP_VERSION="${3/v/}"
	export GIT_TAG="$3"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
    # because we do a patch, we need to reset any changes
    echo git reset --hard
    git reset --hard

	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"
    # reset to the main branch
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}

    # # fetch the latest 
    echo git pull
    git pull

    git checkout tags/${GIT_TAG}
fi

# Change CMakeLists.txt to fix issue with install_name_tool

gsed -i '/get_filename_component(SDL_FULL_PATH "${SDL_LIB}" REALPATH)/a\
\	get_filename_component(SDL_FULL_NAME "${SDL_FULL_PATH}" NAME)' gemrb/CMakeLists.txt

gsed -i 's|\(ADD_CUSTOM_COMMAND(TARGET gemrb PRE_BUILD COMMAND ${CMAKE_INSTALL_NAME_TOOL} -id "@loader_path/../Frameworks/${SDL_BASENAME}"\) "${SDL_FULL_PATH}"|\1 "${BUNDLE_FRAMEWORK_PATH}/${SDL_FULL_NAME}"|' gemrb/CMakeLists.txt

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}
    cd ${ARM64_BUILD_FOLDER}
    cmake  \
    -DDISABLE_WERROR=1  \
    -DCMAKE_OSX_ARCHITECTURES=arm64  \
    -DCMAKE_BUILD_TYPE=Release  \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12  \
    -DCMAKE_PREFIX_PATH=/usr/local  \
    -DPYTHON_LIBRARIES=/Library/Frameworks/Python.framework/Versions/Current/lib/libpython3.12.dylib  \
    -DPYTHON_INCLUDE_DIRS=/Library/Frameworks/Python.framework/Versions/Current/include/python3.12  \
    ..
    # -DLIBVLC_INCLUDE_DIR=/Applications/VLC.app/Contents/MacOS/include \
    # -DLIBVLC_LIBRARY=/Applications/VLC.app/Contents/MacOS/lib/libvlc.dylib \
    cmake --build .
    install_name_tool -add_rpath @executable_path/../Frameworks/. gemrb/${PRODUCT_NAME}.app/Contents/MacOS/gemrb
    mv gemrb/${PRODUCT_NAME}.app ../release

    cd ..

    source ../MSPBuildSystem/common/signing_values.local

    mkdir -p release/gemrb.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python${PYTHON_VERSION}/encodings/
    cp -a /Library/Frameworks/Python.framework/Versions/${PYTHON_VERSION}/lib/libpython${PYTHON_VERSION}.dylib release/gemrb.app/Contents/Frameworks/Python.framework/Versions/Current/lib/
    cp -a /Library/Frameworks/Python.framework/Versions/${PYTHON_VERSION}/lib/python${PYTHON_VERSION}/*.py release/gemrb.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python${PYTHON_VERSION}/
    cp -a /Library/Frameworks/Python.framework/Versions/${PYTHON_VERSION}/lib/python${PYTHON_VERSION}/collections release/gemrb.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python${PYTHON_VERSION}/
    cp -a /Library/Frameworks/Python.framework/Versions/${PYTHON_VERSION}/lib/python${PYTHON_VERSION}/encodings release/gemrb.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python${PYTHON_VERSION}/
    cp -a /Library/Frameworks/Python.framework/Versions/${PYTHON_VERSION}/lib/python${PYTHON_VERSION}/lib-dynload release/gemrb.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python${PYTHON_VERSION}/
    cp -a /Library/Frameworks/Python.framework/Versions/${PYTHON_VERSION}/lib/python${PYTHON_VERSION}/re release/gemrb.app/Contents/Frameworks/Python.framework/Versions/Current/lib/python${PYTHON_VERSION}/
    cp -a /Library/Frameworks/Python.framework/Versions/${PYTHON_VERSION}/Python release/gemrb.app/Contents/Frameworks/Python.framework/Versions/Current/

    find release/gemrb.app/Contents/Frameworks/Python.framework -type f -name "*.so" -exec echo codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" {} \;
    find release/gemrb.app/Contents/Frameworks/Python.framework -type f -name "*.so" -exec codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" {} \;

    echo codesign --force --timestamp --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/Current/Python
    codesign --force --timestamp --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/Current/Python

    install_name_tool -change /Library/Frameworks/Python.framework/Versions/${PYTHON_VERSION}/Python @executable_path/../Frameworks/Python.framework/Versions/Current/Python release/gemrb.app/Contents/PlugIns/GUIScript.so

    cp /usr/local/lib/libSDL2_mixer-2.0.0.dylib release/gemrb.app/Contents/Frameworks
    "../MSPBuildSystem/common/copy_dependencies.sh" release/gemrb.app/Contents/Frameworks/libSDL2_mixer-2.0.0.dylib

    cp /usr/local/lib/libz.1.dylib release/gemrb.app/Contents/Frameworks
    "../MSPBuildSystem/common/copy_dependencies.sh" release/gemrb.app/Contents/Frameworks/libz.1.dylib

    cp /usr/local/lib/libpng16.16.dylib release/gemrb.app/Contents/Frameworks
    "../MSPBuildSystem/common/copy_dependencies.sh" release/gemrb.app/Contents/Frameworks/libpng16.16.dylib

    cp /usr/local/lib/libfreetype.6.dylib release/gemrb.app/Contents/Frameworks
    "../MSPBuildSystem/common/copy_dependencies.sh" release/gemrb.app/Contents/Frameworks/libfreetype.6.dylib
else

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
fi

cp ../MSPBuildSystem/${PROJECT_NAME}/${ICONSFILENAME}.icns ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"