# game/app specific values
export APP_VERSION="1.5.3"
export PRODUCT_NAME="devilutionX"
export PROJECT_NAME="devilutionX"
export PORT_NAME="DevilutionX"
export ICONSFILENAME="devilutionX"
export EXECUTABLE_NAME="devilutionX"
export PKGINFO="APPLEDVLX"
export GIT_TAG="1.5.3"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

if [ -n "$3" ]; then
	echo "Setting version / tag to : " "$3"
	export APP_VERSION="$3"
	export GIT_TAG="$3"
else
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
fi

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    rm -rf ${X86_64_BUILD_FOLDER}
    mkdir ${X86_64_BUILD_FOLDER}
    cd ${X86_64_BUILD_FOLDER}
    cmake  \
    -DBUILD_TESTING=OFF  \
    -DCMAKE_OSX_ARCHITECTURES="x86_64" \
    -DCMAKE_BUILD_TYPE=Release  \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7  \
    ..  \
    -Wno-dev

    cmake --build . --parallel $NCPU

    cd ..

    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}
    cd ${ARM64_BUILD_FOLDER}
    cmake  \
    -DBUILD_TESTING=OFF  \
    -DCMAKE_OSX_ARCHITECTURES="arm64" \
    -DCMAKE_BUILD_TYPE=Release  \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.7  \
    ..  \
    -Wno-dev

    cmake --build . --parallel $NCPU
else
    # create makefiles with cmake
    rm -rf ${X86_64_BUILD_FOLDER}
    mkdir ${X86_64_BUILD_FOLDER}
    cd ${X86_64_BUILD_FOLDER}
    sodium_INCLUDE_DIR=/usr/local/include
    sodium_LIBRARY_DEBUG=/usr/local/lib/libsodium.dylib
    sodium_LIBRARY_RELEASE=/usr/local/lib/libsodium.dylib
    /usr/local/bin/cmake -G "Unix Makefiles" \
    -DBUILD_TESTING=OFF  \
    -DPKG_CONFIG_EXECUTABLE=/usr/local/bin/pkg-config \
    -DCMAKE_C_FLAGS_RELEASE="-arch x86_64"  \
    -DCMAKE_BUILD_TYPE=Release  \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12  \
    -DSDL2_DIR=/usr/local/opt/sdl2/lib/cmake/SDL2  \
    -DSDL2_INCLUDE_DIRS=/usr/local/opt/sdl2/include/SDL2  \
    -DSDL2_image_DIR=/usr/local/lib/cmake/SDL2_image \
    -DSDL2_LIBRARIES=/usr/local/opt/sdl2/lib  \
    -DPKG_CONFIG_EXECUTABLE=/usr/local/bin/pkg-config  \
    -DDEVILUTIONX_SYSTEM_LIBFMT=OFF  \
    ..  \
    -Wno-dev

    cd ..
    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}
    cd ${ARM64_BUILD_FOLDER}
    cmake -G "Unix Makefiles"  \
    -DBUILD_TESTING=OFF  \
    -DCMAKE_BUILD_TYPE=Release  \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.12  \
    ..  \
    -Wno-dev

    # perform builds with make
    cd ..
    cd ${X86_64_BUILD_FOLDER}
    make -j$NCPU

    cd ..
    cd ${ARM64_BUILD_FOLDER}
    make -j$NCPU
fi

cd ..

export EXTRA_INFO_PLIST_ENTRIES="
    <key>CFBundleDisplayName</key>
	<string>DevilutionX</string>
    <key>SDL_FILESYSTEM_BASE_DIR_TYPE</key>
	<string>parent</string>"

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"
    
    cd ${BUILT_PRODUCTS_DIR}
    install_name_tool -add_rpath @executable_path/. ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    cd ..
else
    "../MSPBuildSystem/common/build_app_bundle.sh"
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"