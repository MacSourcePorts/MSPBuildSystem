# game/app specific values
export APP_VERSION="0.1"
export PRODUCT_NAME="OpenEnroth"
export PROJECT_NAME="OpenEnroth"
export PORT_NAME="OpenEnroth"
export ICONSFILENAME="OpenEnroth"
export EXECUTABLE_NAME="OpenEnroth"
export PKGINFO="APPLMM7"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.15"

cd ../../${PROJECT_NAME}

export AR=/usr/bin/ar
export RANLIB=/usr/bin/ranlib

gsed -i 's/IMSTB_TEXTEDIT_CHARTYPE empty_string;/IMSTB_TEXTEDIT_CHARTYPE empty_string = 0;/' thirdparty/imgui/imgui/imgui_widgets.cpp

rm -rf ${BUILT_PRODUCTS_DIR}

export OpenAL_DIR=/usr/local/opt/openal-soft

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
cmake \
-DPKG_CONFIG_EXECUTABLE=/usr/local/bin/pkg-config \
-DCMAKE_OSX_ARCHITECTURES="x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
-DOE_BUILD_TESTS=OFF \
-DCMAKE_LIBRARY_PATH=/usr/local/lib \
-DCMAKE_EXE_LINKER_FLAGS="-L/usr/local/lib" \
-DOpenAL_DIR=/usr/local/opt/openal-soft \
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
-DCMAKE_SYSTEM_NAME=Darwin \
-DCMAKE_CROSSCOMPILING=ON \
-DCMAKE_C_COMPILER="/usr/bin/clang" \
..
cmake --build . --parallel $NCPU
mv src/Bin/OpenEnroth/${WRAPPER_NAME} .

cd ..
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake \
-DPKG_CONFIG_EXECUTABLE=/usr/local/bin/pkg-config \
-DCMAKE_OSX_ARCHITECTURES="arm64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
-DOE_BUILD_TESTS=OFF \
-DCMAKE_LIBRARY_PATH=/usr/local/lib \
-DCMAKE_EXE_LINKER_FLAGS="-L/usr/local/lib" \
-DOpenAL_DIR=/usr/local/opt/openal-soft \
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
..
cmake --build . --parallel $NCPU
mv src/Bin/OpenEnroth/${WRAPPER_NAME} .

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

cp -a resources/shaders ${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/shaders

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"