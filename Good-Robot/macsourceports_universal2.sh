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

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
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
    -DBoost_DIR=/usr/local/lib/cmake/Boost-1.86.0 ..
    mkdir -p ${EXECUTABLE_FOLDER_PATH}
    mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}
    cp -a ../../MSPBuildSystem/Good-Robot/fragment.cg ${UNLOCALIZED_RESOURCES_FOLDER_PATH}

    cmake --build . --parallel $NCPU
    cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
    install_name_tool -add_rpath @executable_path/. ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
else
    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}
    cd ${ARM64_BUILD_FOLDER}
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DOPENAL_LIBRARY=/opt/homebrew/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/opt/homebrew/opt/openal-soft/include -Wno-dev -DSDL2_LIBRARIES=/opt/homebrew/lib/libSDL2.dylib -DSDL2_LDFLAGS="-L/opt/homebrew/lib/libSDL2.dylib;-lSDL2" -DGLEW_LIBRARIES=/opt/homebrew/lib/libGLEW.dylib  ..
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
    /usr/local/bin/cmake -G "Unix Makefiles" -DCMAKE_OSX_ARCHITECTURES=x86_64 -DCMAKE_BUILD_TYPE=Release -DOPENAL_LIBRARY=/usr/local/opt/openal-soft/lib/libopenal.dylib -DOPENAL_INCLUDE_DIR=/usr/local/opt/openal-soft/include -Wno-dev -DSDL2_LIBRARIES=/usr/local/lib/libSDL2.dylib -DSDL2_LDFLAGS="-L/usr/local/lib/libSDL2.dylib;-lSDL2" -DGLEW_LIBRARIES=/usr/local/lib/libGLEW.dylib -DPKG_CONFIG_EXECUTABLE=/usr/local/bin/pkg-config -DBoost_DIR=/usr/local/lib/cmake/Boost-1.79.0 ..
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
fi

cd ..

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"
else
    "../MSPBuildSystem/common/build_app_bundle.sh"
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"