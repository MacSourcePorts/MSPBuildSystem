# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="1oom"
export PROJECT_NAME="1oom"
export PORT_NAME="1oom"
export ICONSFILENAME="1oom"
export EXECUTABLE_NAME="1oom_classic_sdl2"
export PKGINFO="APPLBGDM"
export GIT_DEFAULT_BRANCH="main"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

if [ -n "$3" ]; then
	export APP_VERSION="${3/v/}"
	export GIT_TAG="$3"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"

    # reset to the main branch
    # echo git checkout ${GIT_DEFAULT_BRANCH}
    # git checkout ${GIT_DEFAULT_BRANCH}

    # # fetch the latest 
    # echo git pull
    # git pull
fi

autoreconf -fi

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}

cd ${BUILT_PRODUCTS_DIR}
../configure --disable-hwsdl1gl CFLAGS="-arch arm64 -arch x86_64  -mmacosx-version-min=10.7"
make -j$NCPU
mv src/1oom_* ${EXECUTABLE_FOLDER_PATH}
make clean

"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"