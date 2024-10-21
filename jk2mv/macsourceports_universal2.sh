# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="jk2mvmp"
export PROJECT_NAME="jk2mv"
export PORT_NAME="jk2mv"
export ICONSFILENAME="jk2mv"
export EXECUTABLE_NAME="jk2mvmp"
export PKGINFO="APPLEJ2MV"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

export ARM64_PREFIX_PATH=/opt/Homebrew
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	echo "Skipping git because we're on the build server"
    export ARM64_PREFIX_PATH=/usr/local
	export RANLIB=/usr/bin/ranlib
else
    # reset to the main branch
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}

    # fetch the latest 
    echo git pull
    git pull

    # for this one we have to check out latest on the mvsdk repo as well
    # TODO: still necessary? 
    echo cd src/mvsdk
    cd src/mvsdk
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}
    echo git pull
    git pull
    echo cd ../../
    cd ../../

fi

# we just do the latest on this one as they haven't had a release tag since 2018

rm -rf ${BUILT_PRODUCTS_DIR}

#create makefiles with cmake, perform builds with make
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
cmake \
-DUseInternalLibs=ON \
-DBuildPortableVersion=OFF \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 \
-DCMAKE_INSTALL_PREFIX=./install \
-DCMAKE_OSX_ARCHITECTURES=x86_64 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_TOOLCHAIN_FILE=../../MSPBuildSystem/jk2mv/x86_64.cmake \
..
cmake --build . --parallel -j$NCPU
# make -j$NCPU
cd ..

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake \
-DUseInternalLibs=ON \
-DBuildPortableVersion=OFF \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.12 \
-DCMAKE_INSTALL_PREFIX=./install \
-DCMAKE_OSX_ARCHITECTURES=arm64 \
-DCMAKE_PREFIX_PATH=$ARM64_PREFIX_PATH\
-DCMAKE_TOOLCHAIN_FILE=../../MSPBuildSystem/jk2mv/arm64.cmake \
..
cmake --build . --parallel -j$NCPU
# make -j$NCPU
cd ..

cp ${X86_64_BUILD_FOLDER}/out/Release/jk2mvmenu_x86_64.dylib ${X86_64_BUILD_FOLDER}/out/Release/jk2mvmp.app/Contents/MacOS
mv ${X86_64_BUILD_FOLDER}/out/Release/jk2mvmp.app ${X86_64_BUILD_FOLDER}

cp ${ARM64_BUILD_FOLDER}/out/Release/jk2mvmenu_arm64.dylib ${ARM64_BUILD_FOLDER}/out/Release/jk2mvmp.app/Contents/MacOS
mv ${ARM64_BUILD_FOLDER}/out/Release/jk2mvmp.app ${ARM64_BUILD_FOLDER}

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

mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base"
echo cp -a "${X86_64_BUILD_FOLDER}/out/Release/base/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base"
cp -a "${X86_64_BUILD_FOLDER}/out/Release/base/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base"

cp ${X86_64_BUILD_FOLDER}/out/Release/jk2mvmenu_x86_64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${ARM64_BUILD_FOLDER}/out/Release/jk2mvmenu_arm64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}

export ENTITLEMENTS_FILE="build/jk2mv.entitlements"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"