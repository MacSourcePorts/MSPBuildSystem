# game/app specific values
export APP_VERSION="0.20"
export ICONSFILENAME="xash3d-fwgs"
export PRODUCT_NAME="Xash3D-FWGS"
export PROJECT_NAME="xash3d-fwgs"
export PORT_NAME="Xash3D-FWGS"
export EXECUTABLE_NAME="xash3d"
export PKGINFO="APPLMLST"
export GIT_DEFAULT_BRANCH="main"
export ENTITLEMENTS_FILE="../MSPBuildSystem/xash3d-fwgs/xash3d-fwgs.entitlements"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

# # reset to the main branch
# echo git checkout ${GIT_DEFAULT_BRANCH}
# git checkout ${GIT_DEFAULT_BRANCH}

# # fetch the latest 
# echo git pull
# git pull

# Step 1: Xash3D-FWGS
echo "Step 1: Xash3D-FWGS"

rm -rf build
rm -rf ${BUILT_PRODUCTS_DIR}

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}

TEMP_PATH="$PATH"

echo TEMP_PATH = $TEMP_PATH

# Step 1.1: Xash3D-FWGS - Apple Silicon (arm64)
echo "Step 1.1: Xash3D-FWGS - Apple Silicon (arm64)"

(PATH="/opt/homebrew/Cellar/binutils/2.39_1/bin:$TEMP_PATH" ./waf configure --64bits -T release --sdl-use-pkgconfig)
echo PATH = $PATH
./waf build
./waf install --destdir=${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
./waf install --destdir=${ARM64_BUILD_FOLDER}/install

mkdir ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/cl_dlls
mkdir ${ARM64_BUILD_FOLDER}/install/cl_dlls
mkdir ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/dlls
mkdir ${ARM64_BUILD_FOLDER}/install/dlls

# Step 1.2: Xash3D-FWGS - Intel (amd64)
echo "Step 1.2: Xash3D-FWGS - Intel (amd64)"

(CC="clang -arch x86_64" CXX="clang++ -arch x86_64" PATH="/usr/local/Cellar/binutils/2.39_1/bin:$TEMP_PATH" PKGCONFIG=/usr/local/bin/pkg-config ./waf configure --64bits -T release --sdl-use-pkgconfig)
echo PATH = $PATH
./waf build
./waf install --destdir=${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
./waf install --destdir=${X86_64_BUILD_FOLDER}/install

mkdir ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/cl_dlls
mkdir ${X86_64_BUILD_FOLDER}/install/cl_dlls
mkdir ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/dlls
mkdir ${X86_64_BUILD_FOLDER}/install/dlls

# Step 2: HLSDK
echo "Step 2: HLSDK"

cd ../hlsdk-portable

# Step 2.1 : HLSDK - Half-Life
echo "Step 2.1 : HLSDK - Half-Life"

git checkout master

# Step 2.1.1 : HLSDK - Half-Life - Apple Silicon (arm64)
echo "Step 2.1.1 : HLSDK - Half-Life - Apple Silicon (arm64)"

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake ..
make -j$NCPU

mv cl_dll cl_dlls
if [ -f cl_dlls/client.dylib ]; then
	mv cl_dlls/client.dylib cl_dlls/client_arm64.dylib
fi
rm cl_dlls/cmake_install.cmake
rm -rf cl_dlls/CMakeFiles
rm cl_dlls/Makefile

if [ -f dlls/hl.dylib ]; then
	mv dlls/hl.dylib dlls/hl_arm64.dylib
fi
rm dlls/cmake_install.cmake
rm -rf dlls/CMakeFiles
rm dlls/Makefile

cp -a cl_dlls/* ../../${PROJECT_NAME}/${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/cl_dlls
cp -a cl_dlls/* ../../${PROJECT_NAME}/${ARM64_BUILD_FOLDER}/install/cl_dlls
cp -a dlls/* ../../${PROJECT_NAME}/${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/dlls
cp -a dlls/* ../../${PROJECT_NAME}/${ARM64_BUILD_FOLDER}/install/dlls

cd ..

# Step 2.1.2 : HLSDK - Half-Life - Intel (amd64)
echo "Step 2.1.2 : HLSDK - Half-Life - Intel (amd64)"

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
cmake -DCMAKE_OSX_ARCHITECTURES=x86_64 ..
make -j$NCPU

mv cl_dll cl_dlls
if [ -f cl_dlls/client.dylib ]; then
	mv cl_dlls/client.dylib cl_dlls/client_amd64.dylib
fi
rm cl_dlls/cmake_install.cmake
rm -rf cl_dlls/CMakeFiles
rm cl_dlls/Makefile

if [ -f dlls/hl.dylib ]; then
	mv dlls/hl.dylib dlls/hl_amd64.dylib
fi
rm dlls/cmake_install.cmake
rm -rf dlls/CMakeFiles
rm dlls/Makefile

cp -a cl_dlls/* ../../${PROJECT_NAME}/${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/cl_dlls
cp -a cl_dlls/* ../../${PROJECT_NAME}/${X86_64_BUILD_FOLDER}/install/cl_dlls
cp -a dlls/* ../../${PROJECT_NAME}/${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/dlls
cp -a dlls/* ../../${PROJECT_NAME}/${X86_64_BUILD_FOLDER}/install/dlls

cd ..

# Step 2.2 : HLSDK - Half-Life: Opposing Force
echo "Step 2.2 : HLSDK - Half-Life: Opposing Force"

git checkout opforfixed

# Step 2.2.1 : HLSDK - Half-Life: Opposing Force - Apple Silicon (arm64)
echo "Step 2.2.1 : HLSDK - Half-Life: Opposing Force - Apple Silicon (arm64)"

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake ..
make -j$NCPU

mv cl_dll cl_dlls
if [ -f cl_dlls/client.dylib ]; then
	mv cl_dlls/client.dylib cl_dlls/client_arm64.dylib
fi
rm cl_dlls/cmake_install.cmake
rm -rf cl_dlls/CMakeFiles
rm cl_dlls/Makefile

if [ -f dlls/opfor.dylib ]; then
	mv dlls/opfor.dylib dlls/opfor_arm64.dylib
fi
rm dlls/cmake_install.cmake
rm -rf dlls/CMakeFiles
rm dlls/Makefile

cp -a dlls/* ../../${PROJECT_NAME}/${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/dlls
cp -a dlls/* ../../${PROJECT_NAME}/${ARM64_BUILD_FOLDER}/install/dlls

cd ..

# Step 2.2.2 : HLSDK - Half-Life: Opposing Force - Intel (amd64)
echo "Step 2.2.2 : HLSDK - Half-Life: Opposing Force - Intel (amd64)"

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
cmake -DCMAKE_OSX_ARCHITECTURES=x86_64 ..
make -j$NCPU

mv cl_dll cl_dlls
if [ -f cl_dlls/client.dylib ]; then
	mv cl_dlls/client.dylib cl_dlls/client_amd64.dylib
fi
rm cl_dlls/cmake_install.cmake
rm -rf cl_dlls/CMakeFiles
rm cl_dlls/Makefile

if [ -f dlls/opfor.dylib ]; then
	mv dlls/opfor.dylib dlls/opfor_amd64.dylib
fi
rm dlls/cmake_install.cmake
rm -rf dlls/CMakeFiles
rm dlls/Makefile

cp -a dlls/* ../../${PROJECT_NAME}/${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/dlls
cp -a dlls/* ../../${PROJECT_NAME}/${X86_64_BUILD_FOLDER}/install/dlls

cd ..

# Step 2.3 : HLSDK - Half-Life: Blue Shift
echo "Step 2.3 : HLSDK - Half-Life: Blue Shift"

git checkout bshift

# Step 2.3.1 : HLSDK - Half-Life: Blue Shift - Apple Silicon (arm64)
echo "Step 2.3.1 : HLSDK - Half-Life: Blue Shift - Apple Silicon (arm64)"

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake ..
make -j$NCPU

mv cl_dll cl_dlls
if [ -f cl_dlls/client.dylib ]; then
	mv cl_dlls/client.dylib cl_dlls/client_arm64.dylib
fi
rm cl_dlls/cmake_install.cmake
rm -rf cl_dlls/CMakeFiles
rm cl_dlls/Makefile

if [ -f dlls/bshift.dylib ]; then
	mv dlls/bshift.dylib dlls/bshift_arm64.dylib
fi
rm dlls/cmake_install.cmake
rm -rf dlls/CMakeFiles
rm dlls/Makefile

cp -a dlls/* ../../${PROJECT_NAME}/${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/dlls
cp -a dlls/* ../../${PROJECT_NAME}/${ARM64_BUILD_FOLDER}/install/dlls

cd ..

# Step 2.3.2 : HLSDK - Half-Life: Blue Shift - Intel (amd64)
echo "Step 2.3.2 : HLSDK - Half-Life: Blue Shift - Intel (amd64)"

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
cmake -DCMAKE_OSX_ARCHITECTURES=x86_64 ..
make -j$NCPU

mv cl_dll cl_dlls
if [ -f cl_dlls/client.dylib ]; then
	mv cl_dlls/client.dylib cl_dlls/client_amd64.dylib
fi
rm cl_dlls/cmake_install.cmake
rm -rf cl_dlls/CMakeFiles
rm cl_dlls/Makefile

if [ -f dlls/bshift.dylib ]; then
	mv dlls/bshift.dylib dlls/bshift_amd64.dylib
fi
rm dlls/cmake_install.cmake
rm -rf dlls/CMakeFiles
rm dlls/Makefile

cp -a dlls/* ../../${PROJECT_NAME}/${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/dlls
cp -a dlls/* ../../${PROJECT_NAME}/${X86_64_BUILD_FOLDER}/install/dlls

# Step 3: Build the Universal 2 bundle
cd ../../${PROJECT_NAME}

# dylibbundler libxash
dylibbundler -od -b -x ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libxash.dylib -d ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/ -p @executable_path/${X86_64_LIBS_FOLDER}/
dylibbundler -od -b -x ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libxash.dylib -d ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/ -p @executable_path/${ARM64_LIBS_FOLDER}/

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

echo install_name_tool -add_rpath @executable_path/. ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
install_name_tool -add_rpath @executable_path/. ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}

#create any app-specific directories
if [ ! -d "${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" || exit 1;
fi

cp -a ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/valve ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/valve

#lipo any app-specific things
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/filesystem_stdio.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/filesystem_stdio.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/filesystem_stdio.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libmenu.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libmenu.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libmenu.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libref_gl.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libref_gl.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libref_gl.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libref_soft.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libref_soft.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libref_soft.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libxash.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/libxash.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/libxash.dylib" -create

#copy over game libraries
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/cl_dlls" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/cl_dlls" || exit 1;
fi

cp -a ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/cl_dlls/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/cl_dlls
cp -a ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/cl_dlls/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/cl_dlls

if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/dlls" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/dlls" || exit 1;
fi

cp -a ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/dlls/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/dlls
cp -a ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/dlls/* ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/dlls

# cd ${BUILT_PRODUCTS_DIR}
# dylibbundler -od -b -x "./${EXECUTABLE_FOLDER_PATH}/libxash.dylib" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
# cd ..

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
# "../MSPBuildSystem/common/package_dmg.sh"