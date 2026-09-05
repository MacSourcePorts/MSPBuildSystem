# game/app specific values
export APP_VERSION="0.80"
export PRODUCT_NAME="OpenGothic"
export PROJECT_NAME="OpenGothic"
export PORT_NAME="OpenGothic"
export ICONSFILENAME="opengothic"
export EXECUTABLE_NAME="Gothic2Notr"
export PKGINFO="APPLOGw"
export GIT_DEFAULT_BRANCH="master"
export GIT_TAG="v0.80"

#constants
source ../common/constants.sh
source ../common/signing_values.local

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	export GIT_TAG="$2"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"
fi

gsed -i "s|<fp.h>|<math.h>|" lib/Tempest/Engine/thirdparty/libpng/libpng/pngpriv.h

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}
cmake -H. -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
-DCMAKE_CXX_FLAGS="-Wno-error=nonnull" \
..
cmake --build . --target Gothic2Notr -j $NCPU
cp opengothic/${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"