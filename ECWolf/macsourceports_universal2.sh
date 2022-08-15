# game/app specific values
export APP_VERSION="1.3.99999"
export PRODUCT_NAME="ECWolf"
export PROJECT_NAME="ECWolf"
export PORT_NAME="ECWolf"
export ICONSFILENAME="ECWolf"
export EXECUTABLE_NAME="ecwolf"
export PKGINFO="APPLECWF"
# skipping git tags since this one does not do versioned releases

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

# skipping release tag since this one does not do versioned releases

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake -G "Unix Makefiles" -DCMAKE_OSX_ARCHITECTURES=x86_64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 -DSDL2_DIR=/usr/local/opt/sdl2/lib/cmake/SDL2 -DSDL2_INCLUDE_DIRS=/usr/local/opt/sdl2/include/SDL2 -DSDL2_LIBRARIES=/usr/local/opt/sdl2/lib -DFORCE_SDL12=ON ..

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -G "Unix Makefiles" -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12  -DFORCE_SDL12=ON .. 

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

#copy resources
cp build-x86_64/${EXECUTABLE_FOLDER_PATH}/ecwolf.pk3 "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"