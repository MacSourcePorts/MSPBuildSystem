# game/app specific values
export APP_VERSION="1.5.2"
export PRODUCT_NAME="dhewm3"
export PROJECT_NAME="dhewm3"
export PORT_NAME="dhewm3"
export ICONSFILENAME="doom3"
export EXECUTABLE_NAME="dhewm3"
export PKGINFO="APPLDHM3"
export GIT_TAG="1.5.2"
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

# check out the latest release tag
# NOTE: skipping for now until I do a PR to search in the app bundle for the game files.
# echo git checkout tags/${GIT_TAG}
# git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake -G "Unix Makefiles" -DCMAKE_C_FLAGS_RELEASE="-arch x86_64" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2=ON -DOPENAL_LIBRARY=/usr/local/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/usr/local/opt/openal-soft/include ../neo -Wno-dev

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2=ON -DOPENAL_LIBRARY=/opt/homebrew/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/opt/homebrew/opt/openal-soft/include ../neo -Wno-dev

# perform builds with make
cd ..
cd ${X86_64_BUILD_FOLDER}
make -j$NCPU

cd ..
cd ${ARM64_BUILD_FOLDER}
make -j$NCPU

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

#create any app-specific directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base" || exit 1;
fi

#lipo any app-specific things
lipo ${X86_64_BUILD_FOLDER}/base.dylib ${ARM64_BUILD_FOLDER}/base.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base/base.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/d3xp.dylib ${ARM64_BUILD_FOLDER}/d3xp.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base/d3xp.dylib" -create

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"