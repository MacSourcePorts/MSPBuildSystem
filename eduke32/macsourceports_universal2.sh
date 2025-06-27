# game/app specific values
export APP_VERSION="2.0"
export PRODUCT_NAME="eduke32"
export PROJECT_NAME="eduke32"
export PORT_NAME="EDuke32"
export ICONSFILENAME="eduke32"
export EXECUTABLE_NAME="eduke32"
export PKGINFO="APPLED32"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh
export STRIP=/usr/bin/strip

cd ../../${PROJECT_NAME}

# If we're on the build server, then we assume we have the latest
# code and we need to copy over our build tweaks
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    cp "../MSPBuildSystem/EDuke32/Common.mak" .
    cp "../MSPBuildSystem/EDuke32/osxbuild.sh" ./platform
else
    # reset to the main branch
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}

    # fetch the latest 
    echo git pull
    git pull
fi

# skipping the checkout bit until the EDuke32 project builds latest on Mac

#fix resolution on cocoa window
export HIGH_RESOLUTION_CAPABLE="true"

rm -rf ${BUILT_PRODUCTS_DIR}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    mkdir ${BUILT_PRODUCTS_DIR}
    cd platform
    ./osxbuild.sh --buildppc=0 --build86=0 --build64=1 --buildarm64=1 --debug=0 --main=1 --tools=0 --pack=0
    cd ..
    mv package/${PRODUCT_NAME}.app ${BUILT_PRODUCTS_DIR}
    "../MSPBuildSystem/common/copy_dependencies.sh" ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
else
    rm -rf ${X86_64_BUILD_FOLDER}
    mkdir ${X86_64_BUILD_FOLDER}

    cd platform
    ./osxbuild.sh --buildppc=0 --build86=0 --build64=1 --buildarm64=0 --debug=0 --main=1 --tools=0 --pack=0
    cd ..

    mv package/${PRODUCT_NAME}.app ${X86_64_BUILD_FOLDER}

    rm -rf ${ARM64_BUILD_FOLDER}
    mkdir ${ARM64_BUILD_FOLDER}

    cd platform
    ./osxbuild.sh --buildppc=0 --build86=0 --build64=0 --buildarm64=1 --debug=0 --main=1 --tools=0 --pack=0
    cd ..

    mv package/${PRODUCT_NAME}.app ${ARM64_BUILD_FOLDER}
fi

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