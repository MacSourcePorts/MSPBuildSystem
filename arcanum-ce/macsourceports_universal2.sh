# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="arcanum-ce"
export PROJECT_NAME="arcanum-ce"
export PORT_NAME="Arcanum Community Edition"
export ICONSFILENAME="arcanum-ce"
export EXECUTABLE_NAME="arcanum-ce"
export PKGINFO="APPLBGDM"
export GIT_DEFAULT_BRANCH="main"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.14"

cd ../../${PROJECT_NAME}

if [ -n "$3" ]; then
	export APP_VERSION="${3/v/}"
	export GIT_TAG="$3"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"
fi

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.14 \
..
cmake --build . --parallel $NCPU

echo mv "Arcanum Community Edition.app" ${WRAPPER_NAME}
mv "Arcanum Community Edition.app" ${WRAPPER_NAME}
mv "${EXECUTABLE_FOLDER_PATH}/Arcanum Community Edition" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}


cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"