# game/app specific values
export APP_VERSION="1.1"
export PRODUCT_NAME="Good-Robot"
export PROJECT_NAME="Good-Robot"
export PORT_NAME="Good Robot"
export ICONSFILENAME="Good-Robot"
export EXECUTABLE_NAME="good_robot"
export PKGINFO="APPLGR"
export GIT_TAG="1.5.2"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

# reset to the main branch
# echo git checkout ${GIT_DEFAULT_BRANCH}
# git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
# echo git pull
# git pull

# check out the latest release tag
# NOTE: skipping for now until I do a PR to search in the app bundle for the game files.
# echo git checkout tags/${GIT_TAG}
# git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DOPENAL_LIBRARY=/opt/homebrew/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/opt/homebrew/opt/openal-soft/include -Wno-dev -DSDL2_LIBRARIES=/opt/homebrew/lib/libSDL2.dylib -DSDL2_LDFLAGS="-L/opt/homebrew/lib/libSDL2.dylib;-lSDL2" -DGLEW_LIBRARIES=/opt/homebrew/lib/libGLEW.dylib -DGLEW_LIBRARY_DEBUG=/opt/homebrew/lib/libGLEW.dylib -DGLEW_LIBRARY_RELEASE=/opt/homebrew/lib/libGLEW.dylib ..
mkdir -p ${EXECUTABLE_FOLDER_PATH}
# mkdir "core"
# cp -a ../../MSPBuildSystem/Good-Robot/core/* "core"
# cp -a ../../MSPBuildSystem/Good-Robot/fragment.cg "core/shaders"
mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cp -a ../../MSPBuildSystem/Good-Robot/fragment.cg ${UNLOCALIZED_RESOURCES_FOLDER_PATH}

cd ..
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake -G "Unix Makefiles" -DCMAKE_OSX_ARCHITECTURES=x86_64 -DCMAKE_BUILD_TYPE=Release -DOPENAL_LIBRARY=/usr/local/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/usr/local/opt/openal-soft/include -Wno-dev -DSDL2_LIBRARIES=/usr/local/lib/libSDL2.dylib -DSDL2_LDFLAGS="-L/usr/local/lib/libSDL2.dylib;-lSDL2" -DGLEW_LIBRARIES=/usr/local/lib/libGLEW.dylib -DPKG_CONFIG_EXECUTABLE=/usr/local/bin/pkg-config -DBoost_DIR=/usr/local/lib/cmake/Boost-1.79.0 -DGLEW_LIBRARY_DEBUG=/opt/homebrew/lib/libGLEW.dylib -DGLEW_LIBRARY_RELEASE=/opt/homebrew/lib/libGLEW.dylib ..
mkdir -p ${EXECUTABLE_FOLDER_PATH}
# # mkdir "core"
# # cp -a ../../MSPBuildSystem/Good-Robot/core/* "core"
# # cp -a ../../MSPBuildSystem/Good-Robot/fragment.cg "core/shaders"
mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cp -a ../../MSPBuildSystem/Good-Robot/fragment.cg ${UNLOCALIZED_RESOURCES_FOLDER_PATH}

# perform builds with make
cd ..
cd ${ARM64_BUILD_FOLDER}
make -j$NCPU #VERBOSE=1
echo cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}

cd ..
cd ${X86_64_BUILD_FOLDER}
make -j$NCPU #VERBOSE=1
echo cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"