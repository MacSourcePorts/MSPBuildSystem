# game/app specific values
export APP_VERSION="1.5.1"
export PRODUCT_NAME="RBDoom3BFG"
export PROJECT_NAME="RBDOOM-3-BFG"
export PORT_NAME="RBDOOM-3-BFG"
export EXECUTABLE_NAME="RBDoom3BFG"
export ICONSFILENAME="RBDoom3BFG"
export PKGINFO="APPLRBD3"
export GIT_TAG="v1.5.1"
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
echo git checkout tags/${GIT_TAG}
git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
cmake -G "Unix Makefiles" \
-DCMAKE_OSX_ARCHITECTURES=x86_64 \
-DCMAKE_C_FLAGS_RELEASE="-arch x86_64" \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 \
-DSDL2=ON \
-DFFMPEG=OFF \
-DBINKDEC=ON \
-DOPENAL_LIBRARY=/usr/local/opt/openal-soft/lib/libopenal.dylib \
-DOPENAL_INCLUDE_DIR=/usr/local/opt/openal-soft/include \
../neo \
-Wno-dev

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -G "Unix Makefiles" \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 \
-DSDL2=ON \
-DFFMPEG=OFF \
-DBINKDEC=ON \
-DOPENAL_LIBRARY=/opt/homebrew/opt/openal-soft/lib/libopenal.dylib \
-DOPENAL_INCLUDE_DIR=/opt/homebrew/opt/openal-soft/include \
../neo \
-Wno-dev

# perform builds with make
cd ..
cd ${X86_64_BUILD_FOLDER}
make -j$NCPU
mkdir -p ${EXECUTABLE_FOLDER_PATH}
mv ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}

cd ..
cd ${ARM64_BUILD_FOLDER}
make -j$NCPU
mkdir -p ${EXECUTABLE_FOLDER_PATH}
mv ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

#create any app-specific directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/idlib" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/idlib" || exit 1;
fi

#lipo any app-specific things
lipo ${X86_64_BUILD_FOLDER}/idlib/libidlib.a ${ARM64_BUILD_FOLDER}/idlib/libidlib.a -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/idlib/libidlib.a" -create

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"