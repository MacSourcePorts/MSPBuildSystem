# game/app specific values
export APP_VERSION="1.6.0"
export PRODUCT_NAME="RBDoom3BFG"
export PROJECT_NAME="RBDOOM-3-BFG"
export PORT_NAME="RBDOOM-3-BFG"
export EXECUTABLE_NAME="RBDoom3BFG"
export ICONSFILENAME="RBDoom3BFG"
export PKGINFO="APPLRBD3"
export GIT_TAG="v1.6.0"
export GIT_DEFAULT_BRANCH="rpsubsets-and-pc"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	echo "Skipping git because we're on the build server"

	# reset to the main branch
	echo git checkout ${GIT_DEFAULT_BRANCH}
	git checkout ${GIT_DEFAULT_BRANCH}
else
	# because we do a patch, we need to reset any changes
	echo git reset --hard
	git reset --hard

	# reset to the main branch
	echo git checkout ${GIT_DEFAULT_BRANCH}
	git checkout ${GIT_DEFAULT_BRANCH}

	# # fetch the latest 
	echo git pull
	git pull

	# check out the latest release tag
	# echo git checkout tags/${GIT_TAG}
	# git checkout tags/${GIT_TAG}
fi

gsed -i '/#define[[:space:]]\+fdopen(fd,mode)[[:space:]]\+NULL/ d' neo/libs/zlib/zutil.h

export VULKAN_SDK=~/VulkanSDK/1.4.313.0/macOS
export DYLD_LIBRARY_PATH=$VULKAN_SDK/lib:$DYLD_LIBRARY_PATH
export CMAKE_PREFIX_PATH=$VULKAN_SDK:$CMAKE_PREFIX_PATH

rm -rf ${BUILT_PRODUCTS_DIR}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	mkdir ${BUILT_PRODUCTS_DIR}
	cd ${BUILT_PRODUCTS_DIR}

	cmake \
	-G "Unix Makefiles" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	-DCMAKE_C_FLAGS_RELEASE="-DNDEBUG" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
	-DCMAKE_PREFIX_PATH=/usr/local:$VULKAN_SDK \
	-DSDL2_DIR:PATH=/usr/local/lib/cmake/SDL2 \
	-DFFMPEG=OFF \
	-DBINKDEC=ON \
	-DUSE_MoltenVK=ON \
	-DOPENAL_LIBRARY=/usr/local/lib/libopenal.dylib \
	-DOPENAL_INCLUDE_DIR=/usr/local/include  \
	../neo -Wno-dev

    cmake --build . --parallel $NCPU

	mkdir -p ${EXECUTABLE_FOLDER_PATH}
	mv ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}

    install_name_tool -add_rpath @executable_path/. ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
else
	rm -rf ${X86_64_BUILD_FOLDER}
	mkdir ${X86_64_BUILD_FOLDER}
	cd ${X86_64_BUILD_FOLDER}

	cmake \
	-G "Unix Makefiles" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_OSX_ARCHITECTURES=x86_64 \
	-DCMAKE_C_FLAGS_RELEASE="-DNDEBUG" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
	-DCMAKE_PREFIX_PATH=/usr/local:$VULKAN_SDK \
	-DSDL2_DIR:PATH=/usr/local/lib/cmake/SDL2 \
	-DFFMPEG=OFF \
	-DBINKDEC=ON \
	-DUSE_MoltenVK=ON \
	-DOPENAL_LIBRARY=/usr/local/opt/openal-soft/lib/libopenal.dylib \
	-DOPENAL_INCLUDE_DIR=/usr/local/opt/openal-soft/include  \
	../neo -Wno-dev

	cd ..
	rm -rf ${ARM64_BUILD_FOLDER}
	mkdir ${ARM64_BUILD_FOLDER}
	cd ${ARM64_BUILD_FOLDER}

	cmake \
	-G "Unix Makefiles" \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_C_FLAGS_RELEASE="-DNDEBUG" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
	-DCMAKE_PREFIX_PATH=/opt/homebrew:$VULKAN_SDK \
	-DFFMPEG=OFF \
	-DBINKDEC=ON \
	-DUSE_MoltenVK=ON \
	-DOPENAL_LIBRARY=/opt/homebrew/opt/openal-soft/lib/libopenal.dylib \
	-DOPENAL_INCLUDE_DIR=/opt/homebrew/opt/openal-soft/include  \
	../neo -Wno-dev

	# perform builds with make
	cd ..
	cd ${X86_64_BUILD_FOLDER}
	make -j$NCPU
	mkdir -p ${EXECUTABLE_FOLDER_PATH}
	install_name_tool -change @rpath/libMoltenVK.dylib /usr/local/lib/libMoltenVK.dylib ${EXECUTABLE_NAME}
	mv ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}

	cd ..
	cd ${ARM64_BUILD_FOLDER}
	make -j$NCPU
	mkdir -p ${EXECUTABLE_FOLDER_PATH}
	install_name_tool -change @rpath/libMoltenVK.dylib /opt/homebrew/lib/libMoltenVK.dylib ${EXECUTABLE_NAME}
	mv ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
fi

cd ..

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"
else
	"../MSPBuildSystem/common/build_app_bundle.sh"
fi

#create any app-specific directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/base" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/base" || exit 1;
	cp -a base/* "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/base"
	if [ "$3" == "full" ]; then
		cp -a ../MSPBuildSystem/${PROJECT_NAME}/data/* "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/base"
	fi
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"