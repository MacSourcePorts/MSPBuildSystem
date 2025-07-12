# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="Akhenaten"
export PROJECT_NAME="Akhenaten"
export PORT_NAME="Akhenaten"
export ICONSFILENAME="akhenaten"
export EXECUTABLE_NAME="akhenaten"
export GIT_TAG="v1.0"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

if [ -n "$3" ]; then
	export APP_VERSION="${3/v/}"
	export GIT_TAG="$3"
	echo "Setting version / tag to: " "$APP_VERSION" / "$GIT_TAG"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"

	# because we do a patch, we need to reset any changes
	echo git reset --hard
	git reset --hard

    # reset to the main branch
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}

    # fetch the latest 
    echo git pull
    git pull

	# skipping checkout since we just use the latest on this one
fi

rm -rf ${BUILT_PRODUCTS_DIR}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    gsed -i "s|<fp.h>|<math.h>|" ext/png/pngpriv.h

    gsed -i '/# *define *fdopen *(fd, *mode) *NULL/ i\
#if !defined(__APPLE__)
' ext/zlib/zutil.h

gsed -i '/# *define *fdopen *(fd, *mode) *NULL/ a\
#endif
' ext/zlib/zutil.h

    mkdir ${BUILT_PRODUCTS_DIR}
    cd ${BUILT_PRODUCTS_DIR}
    cmake \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7 \
    ..
    cmake --build . --parallel $NCPU
    install_name_tool -add_rpath @executable_path/. ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
else
    # create makefiles with cmake, perform builds with make
    rm -rf ${X86_64_BUILD_FOLDER}
    mkdir ${X86_64_BUILD_FOLDER}
    cd ${X86_64_BUILD_FOLDER}
    /usr/local/bin/cmake ..
    make -j$NCPU

    cd ..
    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}
    cd ${ARM64_BUILD_FOLDER}
    cmake ..
    make -j$NCPU
fi

cd ..

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"
else
    "../MSPBuildSystem/common/build_app_bundle.sh"
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"