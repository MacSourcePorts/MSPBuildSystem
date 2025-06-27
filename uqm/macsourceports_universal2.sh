# game/app specific values
export APP_VERSION="0.8.0"
export ICONSFILENAME="uqm"
export PROJECT_NAME="uqm"
export PRODUCT_NAME="The Ur-Quan Masters"
export PORT_NAME="uqm"
export EXECUTABLE_NAME="The Ur-Quan Masters"
export PKGINFO="APPLMLST"
export GIT_DEFAULT_BRANCH="main"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	echo "Skipping git because we're on the build server"
else
    # reset to the main branch
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}

    # fetch the latest 
    echo git pull
    git pull
fi

rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

#create any app-specific directories
if [ ! -d "dist-packages" ]; then
	mkdir -p "dist-packages" || exit 1;
    cp -a ../MSPBuildSystem/uqm/dist-packages/* dist-packages
fi

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    ./build.sh uqm clean
    cp "../MSPBuildSystem/uqm/config_unix.h" .
    cp "../MSPBuildSystem/uqm/build.vars.x86_64" "build.vars"
    (ARCH=x86_64 ./build.sh uqm -j$NCPU)
    build/unix_installer/copy_mac_frameworks.pl
    mv "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/packages/uqm-0.8.0-3domusic.uqm" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/addons"
    mv "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/packages/uqm-0.8.0-voice.uqm" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/addons"
    mv "${WRAPPER_NAME}" ${X86_64_BUILD_FOLDER}

    ./build.sh uqm clean
    cp "../MSPBuildSystem/uqm/config_unix.h" .
    cp "../MSPBuildSystem/uqm/build.vars.arm64" "build.vars"
    (ARCH=arm64 ./build.sh uqm -j$NCPU)
    build/unix_installer/copy_mac_frameworks.pl
    mv "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/packages/uqm-0.8.0-3domusic.uqm" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/addons"
    mv "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/packages/uqm-0.8.0-voice.uqm" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/addons"
    mv "${WRAPPER_NAME}" ${ARM64_BUILD_FOLDER}
else
    ./build.sh uqm clean
    (PKG_CONFIG_PATH=/usr/local/lib/pkgconfig CFLAGS="-I/usr/local/include" LDFLAGS="-L/usr/local/lib" ARCH=x86_64 ./build.sh uqm -j$NCPU)
    build/unix_installer/copy_mac_frameworks.pl
    mv "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/packages/uqm-0.8.0-3domusic.uqm" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/addons"
    mv "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/packages/uqm-0.8.0-voice.uqm" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/addons"
    mv "${WRAPPER_NAME}" ${X86_64_BUILD_FOLDER}

    ./build.sh uqm clean
    (ARCH=arm64 ./build.sh uqm -j$NCPU)
    build/unix_installer/copy_mac_frameworks.pl
    mv "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/packages/uqm-0.8.0-3domusic.uqm" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/addons"
    mv "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/packages/uqm-0.8.0-voice.uqm" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}/content/addons"
    mv "${WRAPPER_NAME}" ${ARM64_BUILD_FOLDER}
fi

# create the app bundle
export BUNDLE_ID="com.macsourceports.uqm"
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"

    cd ${BUILT_PRODUCTS_DIR}
    mkdir -p "${FRAMEWORKS_FOLDER_PATH}"
    "../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${FRAMEWORKS_FOLDER_PATH}"
    cd ..
else
    "../MSPBuildSystem/common/build_app_bundle.sh"
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"