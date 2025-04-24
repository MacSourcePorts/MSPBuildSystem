# game/app specific values
export APP_VERSION="1.5.10"
export PRODUCT_NAME="uhexen2"
export PROJECT_NAME="uhexen2"
export PORT_NAME="uHexen2"
export ICONSFILENAME="uhexen2"
export EXECUTABLE_NAME="glhexen2"
export PKGINFO="APPLHXN2"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

# this port is not HiDPI aware
export HIGH_RESOLUTION_CAPABLE="false"

cd ../../${PROJECT_NAME}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	echo "Skipping git because we're on the build server"

# temp debug
    # echo git reset --hard
	# git reset --hard

    gsed -i "s|LDFLAGS =|LDFLAGS = -arch \$\(MACH_TYPE\) -L/usr/local/lib -lSDL|g" engine/hexen2/Makefile
else
    # reset to the main branch
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}

    # # fetch the latest 
    echo git pull
    git pull
fi

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake, perform builds with make
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd engine/hexen2
make clean
make CFLAGS="-arch x86_64 -I/usr/local/include/SDL -mmacosx-version-min=10.6" MACH_TYPE=x86_64 -j$NCPU glh2
cp glhexen2 ../../${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd ../../

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cd engine/hexen2
make clean
make CFLAGS="-arch arm64 -I/usr/local/include/SDL -mmacosx-version-min=10.6" MACH_TYPE=arm64 -j$NCPU glh2
cp glhexen2 ../../${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}

# clean one last time just to get rid of the object files
make clean 
cd ../../

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"
    install_name_tool -add_rpath @executable_path/. "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
    "../MSPBuildSystem/common/copy_dependencies.sh" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

    # copy over sdl2 manually as shim for sdl12-compat
    cp /usr/local/lib/libSDL2-2.0.0.dylib "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"
else 
    "../MSPBuildSystem/common/build_app_bundle.sh"
fi

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"