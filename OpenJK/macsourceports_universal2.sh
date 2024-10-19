# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="OpenJK"
export PROJECT_NAME="OpenJK"
export PORT_NAME="OpenJK"
export ICONSFILENAME="OpenJK"
export EXECUTABLE_NAME="OpenJK"
export PKGINFO="APPLEOJK"
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
fi

# this one doesn't do releases, we just build latest

rm -rf ${BUILT_PRODUCTS_DIR}

#create makefiles with cmake, perform builds with make
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
cmake \
-DCMAKE_INSTALL_PREFIX=./install \
-DCMAKE_OSX_ARCHITECTURES=x86_64 \
-DBuildJK2SPEngine=ON \
-DBuildJK2SPGame=ON \
-DBuildJK2SPRdVanilla=ON \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_BUILD_TYPE=Release \
..
cmake --build . --parallel -j$NCPU --target install
cd ..

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake \
-DCMAKE_INSTALL_PREFIX=./install \
-DCMAKE_OSX_ARCHITECTURES=arm64 \
-DBuildJK2SPEngine=ON \
-DBuildJK2SPGame=ON \
-DBuildJK2SPRdVanilla=ON \
-DCMAKE_PREFIX_PATH=$ARM64_PREFIX_PATH\
-DCMAKE_BUILD_TYPE=Release \
..
cmake --build . --parallel -j$NCPU --target install
cd ..

# First, OpenJK-SP
export PRODUCT_NAME="OpenJK-SP"

# have to re-do all the variables cascading down from PRODUCT_NAME
export WRAPPER_NAME="${PRODUCT_NAME}.app"
export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"
export EXECUTABLE_NAME="openjk_sp"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
export FRAMEWORKS_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Frameworks"

# the file names always have the host OS even when cross compiling. Trying to use CMAKE_SYSTEM_PROCESSOR break things. Have to do this by hand.
rm -rf ${X86_64_BUILD_FOLDER}/openjk_sp.x86_64.app
if [ -d ${X86_64_BUILD_FOLDER}/install/JediAcademy/openjk_sp.x86_64.app ]; then 
    mv ${X86_64_BUILD_FOLDER}/install/JediAcademy/openjk_sp.x86_64.app ${X86_64_BUILD_FOLDER}/${WRAPPER_NAME}
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/openjk_sp.x86_64  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
else
    mv ${X86_64_BUILD_FOLDER}/install/JediAcademy/openjk_sp.arm64.app ${X86_64_BUILD_FOLDER}/${WRAPPER_NAME}
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/openjk_sp.arm64  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jagamearm64.dylib  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jagamex86_64.dylib
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rdsp-vanilla_arm64.dylib  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rdsp-vanilla_x86_64.dylib
fi

rm -rf ${ARM64_BUILD_FOLDER}/openjk_sp.arm64.app
if [ -d ${ARM64_BUILD_FOLDER}/install/JediAcademy/openjk_sp.arm64.app ]; then 
    mv ${ARM64_BUILD_FOLDER}/install/JediAcademy/openjk_sp.arm64.app ${ARM64_BUILD_FOLDER}/${WRAPPER_NAME}
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/openjk_sp.arm64  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
else
    mv ${ARM64_BUILD_FOLDER}/install/JediAcademy/openjk_sp.x86_64.app ${ARM64_BUILD_FOLDER}/${WRAPPER_NAME}
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/openjk_sp.x86_64  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jagamex86_64.dylib  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jagamearm64.dylib
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rdsp-vanilla_x86_64.dylib  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rdsp-vanilla_arm64.dylib
fi

# create the app bundle
# since the one reference in the executable is covered we can skip lipo and dylibbundler in this script
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

#lipo the executable and libs
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -create
mkdir -p "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}" || exit 1;

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    install_name_tool -add_rpath @executable_path/. "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
else
    lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL2-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL2-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libSDL2-2.0.0.dylib" -create
    cp -a ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL2.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
fi

mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/OpenJK"

cd ${X86_64_BUILD_FOLDER}
if [ "$1" != "buildserver" ] && [ "$2" != "buildserver" ]; then
    dylibbundler -od -b -x ./${EXECUTABLE_FOLDER_PATH}/rdsp-vanilla_x86_64.dylib -d ./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/ -p @executable_path/${X86_64_LIBS_FOLDER}/
fi

cd ..
cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rdsp-vanilla_x86_64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jagamex86_64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/OpenJK
if [ "$1" != "buildserver" ] && [ "$2" != "buildserver" ]; then
    mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}"
    cp -a "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}"
fi

cd ${ARM64_BUILD_FOLDER}
if [ "$1" != "buildserver" ] && [ "$2" != "buildserver" ]; then
    dylibbundler -od -b -x ./${EXECUTABLE_FOLDER_PATH}/rdsp-vanilla_arm64.dylib -d ./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/ -p @executable_path/${ARM64_LIBS_FOLDER}/
fi
cd ..

cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rdsp-vanilla_arm64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jagamearm64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/OpenJK

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/rdsp-vanilla_x86_64.dylib
    cp -a /usr/local/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
    cp -a /usr/local/lib/libz.1.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
else
    mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}"
    cp -a "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}"
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"


# Next, OpenJK-MP
export PRODUCT_NAME="OpenJK-MP"

# have to re-do all the variables cascading down from PRODUCT_NAME
export WRAPPER_NAME="${PRODUCT_NAME}.app"
export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"
export EXECUTABLE_NAME="openjk_mp"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
export FRAMEWORKS_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Frameworks"

rm -rf ${X86_64_BUILD_FOLDER}/openjk.x86_64.app
if [ -d ${X86_64_BUILD_FOLDER}/install/JediAcademy/openjk.x86_64.app ]; then 
    mv ${X86_64_BUILD_FOLDER}/install/JediAcademy/openjk.x86_64.app ${X86_64_BUILD_FOLDER}/${WRAPPER_NAME}
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/openjk.x86_64  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
else
    mv ${X86_64_BUILD_FOLDER}/install/JediAcademy/openjk.arm64.app ${X86_64_BUILD_FOLDER}/${WRAPPER_NAME}
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/openjk.arm64  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jampgamearm64.dylib  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jampgamex86_64.dylib
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/cgamearm64.dylib  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/cgamex86_64.dylib
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/uiarm64.dylib  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/uix86_64.dylib
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/jampgamearm64.dylib  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/jampgamex86_64.dylib
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/cgamearm64.dylib  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/cgamex86_64.dylib
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/uiarm64.dylib  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/uix86_64.dylib
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rd-rend2_arm64.dylib  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rd-rend2_x86_64.dylib
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rd-vanilla_arm64.dylib  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rd-vanilla_x86_64.dylib
fi

rm -rf ${ARM64_BUILD_FOLDER}/openjk.arm64.app
if [ -d ${ARM64_BUILD_FOLDER}/install/JediAcademy/openjk.arm64.app ]; then 
    mv ${ARM64_BUILD_FOLDER}/install/JediAcademy/openjk.arm64.app ${ARM64_BUILD_FOLDER}/${WRAPPER_NAME}
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/openjk.arm64  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
else
    mv ${ARM64_BUILD_FOLDER}/install/JediAcademy/openjk.x86_64.app ${ARM64_BUILD_FOLDER}/${WRAPPER_NAME}
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/openjk.x86_64  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jampgamex86_64.dylib  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jampgamearm64.dylib
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/cgamex86_64.dylib  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/cgamearm64.dylib
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/uix86_64.dylib  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/uiarm64.dylib
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/jampgamex86_64.dylib  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/jampgamearm64.dylib
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/cgamex86_64.dylib  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/cgamearm64.dylib
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/uix86_64.dylib  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/uiarm64.dylib
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rd-rend2_x86_64.dylib  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rd-rend2_arm64.dylib
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rd-vanilla_x86_64.dylib  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rd-vanilla_arm64.dylib
fi

# create the app bundle
# since the one reference in the executable is covered we can skip lipo and dylibbundler in this script
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

#lipo the executable and libs
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -create
mkdir -p "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}" || exit 1;

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    install_name_tool -add_rpath @executable_path/. "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
else
    lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL2-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL2-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libSDL2-2.0.0.dylib" -create
    cp -a ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL2.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
fi

mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/OpenJK"
mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base"

cd ${X86_64_BUILD_FOLDER}
if [ "$1" != "buildserver" ] && [ "$2" != "buildserver" ]; then
    dylibbundler -od -b -x ./${EXECUTABLE_FOLDER_PATH}/rd-vanilla_x86_64.dylib -d ./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/ -p @executable_path/${X86_64_LIBS_FOLDER}/
fi
cd ..
cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rd-vanilla_x86_64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jampgamex86_64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/OpenJK
cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/cgamex86_64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/OpenJK
cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/uix86_64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/OpenJK
cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/jampgamex86_64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base
cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/cgamex86_64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base
cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/uix86_64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base
if [ "$1" != "buildserver" ] && [ "$2" != "buildserver" ]; then
    mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}"
    cp -a "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}"
fi

cd ${ARM64_BUILD_FOLDER}
if [ "$1" != "buildserver" ] && [ "$2" != "buildserver" ]; then
    dylibbundler -od -b -x ./${EXECUTABLE_FOLDER_PATH}/rd-vanilla_arm64.dylib -d ./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/ -p @executable_path/${ARM64_LIBS_FOLDER}/
fi
cd ..
cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rd-vanilla_arm64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jampgamearm64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/OpenJK
cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/cgamearm64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/OpenJK
cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/uiarm64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/OpenJK
cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/jampgamearm64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base
cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/cgamearm64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base
cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/base/uiarm64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/base

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/rd-vanilla_x86_64.dylib
    cp -a /usr/local/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
    cp -a /usr/local/lib/libz.1.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
else
    mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}"
    cp -a "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}"
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipdelete" "skipcleanup"



# Finally, OpenJO-SP
export PRODUCT_NAME="OpenJO-SP"

# have to re-do all the variables cascading down from PRODUCT_NAME
export WRAPPER_NAME="${PRODUCT_NAME}.app"
export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"
export EXECUTABLE_NAME="openjo_sp"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
export FRAMEWORKS_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Frameworks"

rm -rf ${X86_64_BUILD_FOLDER}/openjo_sp.x86_64.app

if [ -d ${X86_64_BUILD_FOLDER}/install/JediOutcast/openjo_sp.x86_64.app ]; then
    mv ${X86_64_BUILD_FOLDER}/install/JediOutcast/openjo_sp.x86_64.app ${X86_64_BUILD_FOLDER}/${WRAPPER_NAME}
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/openjo_sp.x86_64  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
else
    mv ${X86_64_BUILD_FOLDER}/install/JediOutcast/openjo_sp.arm64.app ${X86_64_BUILD_FOLDER}/${WRAPPER_NAME}
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/openjo_sp.arm64  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jospgamearm64.dylib  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jospgamex86_64.dylib
    mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rdjosp-vanilla_arm64.dylib  ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rdjosp-vanilla_x86_64.dylib
fi

rm -rf ${ARM64_BUILD_FOLDER}/openjo_sp.arm64.app
if [ -d ${ARM64_BUILD_FOLDER}/install/JediOutcast/openjo_sp.arm64.app ]; then
    mv ${ARM64_BUILD_FOLDER}/install/JediOutcast/openjo_sp.arm64.app ${ARM64_BUILD_FOLDER}/${WRAPPER_NAME}
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/openjo_sp.arm64  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
else
    mv ${ARM64_BUILD_FOLDER}/install/JediOutcast/openjo_sp.x86_64.app ${ARM64_BUILD_FOLDER}/${WRAPPER_NAME}
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/openjo_sp.x86_64  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jospgamex86_64.dylib  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jospgamearm64.dylib
    mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rdjosp-vanilla_x86_64.dylib  ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rdjosp-vanilla_arm64.dylib
fi

# create the app bundle
# since the one reference in the executable is covered we can skip lipo and dylibbundler in this script
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

#lipo the executable and libs
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -create
mkdir -p "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}" || exit 1;

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    install_name_tool -add_rpath @executable_path/. "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
else
    lipo ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL2-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL2-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/libSDL2-2.0.0.dylib" -create
    cp -a ${X86_64_BUILD_FOLDER}/${FRAMEWORKS_FOLDER_PATH}/libSDL2.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
fi

mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/OpenJK"

cd ${X86_64_BUILD_FOLDER}
if [ "$1" != "buildserver" ] && [ "$2" != "buildserver" ]; then
    dylibbundler -od -b -x ./${EXECUTABLE_FOLDER_PATH}/rdjosp-vanilla_x86_64.dylib -d ./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/ -p @executable_path/${X86_64_LIBS_FOLDER}/
fi
cd ..
cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rdjosp-vanilla_x86_64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jospgamex86_64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/OpenJK
if [ "$1" != "buildserver" ] && [ "$2" != "buildserver" ]; then
    mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}"
    cp -a "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}"
fi

cd ${ARM64_BUILD_FOLDER}
if [ "$1" != "buildserver" ] && [ "$2" != "buildserver" ]; then
    dylibbundler -od -b -x ./${EXECUTABLE_FOLDER_PATH}/rdjosp-vanilla_arm64.dylib -d ./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/ -p @executable_path/${ARM64_LIBS_FOLDER}/
fi

cd ..
cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/rdjosp-vanilla_arm64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
cp ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/OpenJK/jospgamearm64.dylib ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/OpenJK

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/rdjosp-vanilla_x86_64.dylib
    cp -a /usr/local/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
    cp -a /usr/local/lib/libz.1.dylib "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
else
    mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}"
    cp -a "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}"
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipdelete"