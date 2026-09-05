# game/app specific values
export APP_VERSION="1.1"
export PRODUCT_NAME="Good-Robot"
export PROJECT_NAME="Good-Robot"
export PORT_NAME="Good Robot"
export ICONSFILENAME="Good-Robot"
export EXECUTABLE_NAME="good_robot"
export PKGINFO="APPLGR"
export GIT_TAG="1.1"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.8"

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}

cmake -G "Unix Makefiles" \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_BUILD_TYPE=Release \
-DOPENAL_LIBRARY=/usr/local/lib/libopenal.dylib \
-DOPENAL_INCLUDE_DIR=/usr/local/include \
-Wno-dev \
-DSDL2_LIBRARIES=/usr/local/lib/libSDL2.dylib \
-DSDL2_LDFLAGS="-L/usr/local/lib/libSDL2.dylib;-lSDL2" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
-DGLEW_LIBRARIES=/usr/local/lib/libGLEW.dylib \
-DGLEW_LIBRARY_DEBUG=/usr/local/lib/libGLEW.dylib \
-DGLEW_LIBRARY_RELEASE=/usr/local/lib/libGLEW.dylib \
-DPKG_CONFIG_EXECUTABLE=/usr/local/bin/pkg-config \
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
-DBoost_DIR=/usr/local/lib/cmake/Boost-1.86.0 ..
mkdir -p ${EXECUTABLE_FOLDER_PATH}
mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}
cp -a ../../MSPBuildSystem/Good-Robot/fragment.cg ${UNLOCALIZED_RESOURCES_FOLDER_PATH}

cmake --build . --parallel $NCPU
cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

cd ..

"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"