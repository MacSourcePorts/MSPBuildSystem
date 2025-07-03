# game/app specific values
export APP_VERSION="0.6.0"
export PROJECT_NAME="dxx-rebirth"
# because this project does two different app builds
# further game/app specific values are handled below

# constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.13"

# this port is not HiDPI aware
export HIGH_RESOLUTION_CAPABLE="false"

cd ../../${PROJECT_NAME}

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}

#because this port does so much of the work itself all we need to do is 
#run the build command twice for the two platforms
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    rm -rf ${X86_64_BUILD_FOLDER}
    scons opengl=1 sdlmixer=1 d1x=1 d2x=1 macos_add_frameworks=0 builddir=${X86_64_BUILD_FOLDER} --config=force CPPFLAGS="-mmacosx-version-min=10.13 -arch x86_64" CXXFLAGS="-mmacosx-version-min=10.13 -arch x86_64" LINKFLAGS="-mmacosx-version-min=10.13 -arch x86_64" -j$NCPU

    rm -rf ${ARM64_BUILD_FOLDER}
    scons opengl=1 sdlmixer=1 d1x=1 d2x=1 macos_add_frameworks=0 builddir=${ARM64_BUILD_FOLDER} --config=force CPPFLAGS="-mmacosx-version-min=10.13 -arch arm64" CXXFLAGS="-mmacosx-version-min=10.13 -arch arm64" LINKFLAGS="-mmacosx-version-min=10.13 -arch arm64" -j$NCPU
else
    # reset to the main branch
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}

    # fetch the latest 
    echo git pull
    git pull

    # because this project has not done a release or tag since 2018
    # we're just doing the latest to get the latest code and improvements

    rm -rf ${X86_64_BUILD_FOLDER}
    /usr/local/bin/scons opengl=1 sdlmixer=1 d1x=1 d2x=1 macos_add_frameworks=0 builddir=${X86_64_BUILD_FOLDER} PKG_CONFIG=/usr/local/bin/pkg-config --config=force CPPFLAGS=-mmacosx-version-min=10.13 CXXFLAGS=-mmacosx-version-min=10.13 LINKFLAGS=-mmacosx-version-min=10.13 -j$NCPU

    rm -rf ${ARM64_BUILD_FOLDER}
    scons opengl=1 sdlmixer=1 d1x=1 d2x=1 macos_add_frameworks=0 builddir=${ARM64_BUILD_FOLDER} --config=force CPPFLAGS=-mmacosx-version-min=10.13 CXXFLAGS=-mmacosx-version-min=10.13 LINKFLAGS=-mmacosx-version-min=10.13 -j$NCPU
fi 

#descent1 values
export PRODUCT_NAME="D1X-Rebirth"
export ICONSFILENAME="d1x-rebirth"
export EXECUTABLE_NAME="d1x-rebirth"
export PKGINFO="APPLD1XR"

# have to re-do all the variables cascading down from PRODUCT_NAME
export WRAPPER_NAME="${PRODUCT_NAME}.app"
export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
export FRAMEWORKS_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Frameworks"
export ICONS="${ICONSFILENAME}.icns"

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"
    
    cd ${BUILT_PRODUCTS_DIR}
    "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
    cd ..
else
    "../MSPBuildSystem/common/build_app_bundle.sh"
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg (and don't clean up the build artifacts)
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"

#descent2 values
export PRODUCT_NAME="D2X-Rebirth"
export ICONSFILENAME="d2x-rebirth"
export EXECUTABLE_NAME="d2x-rebirth"
export PKGINFO="APPLD2XR"

# have to re-do all the variables cascading down from PRODUCT_NAME
export WRAPPER_NAME="${PRODUCT_NAME}.app"
export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
export FRAMEWORKS_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Frameworks"
export ICONS="${ICONSFILENAME}.icns"

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"
    
    cd ${BUILT_PRODUCTS_DIR}
    "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
    cd ..
else
    "../MSPBuildSystem/common/build_app_bundle.sh"
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg (and don't delete the previous one)
"../MSPBuildSystem/common/package_dmg.sh" "skipdelete"
