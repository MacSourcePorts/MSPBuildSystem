# game/app specific values
export APP_VERSION="1.5.3"
export PRODUCT_NAME="devilutionX"
export PROJECT_NAME="devilutionX"
export PORT_NAME="DevilutionX"
export ICONSFILENAME="devilutionX"
export EXECUTABLE_NAME="devilutionX"
export PKGINFO="APPLEDVLX"

# constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.12"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

# fmt 12 (in /usr/local) moved fmt::format out of <fmt/core.h>, which this release
# and SDL_audiolib rely on, and the bundled fmt 10.0.0 doesn't compile with current
# clang. Build against a bundled fmt 11.2.0 instead, whose core.h still includes format.h.
gsed -i 's|fmt/archive/refs/tags/10.0.0.tar.gz|fmt/archive/refs/tags/11.2.0.tar.gz|; s|MD5=fa629bc1178918b7af4b2ea6b6a271dc|MD5=2f3701cada629ca455c3388d1089f5bd|' 3rdParty/libfmt/CMakeLists.txt

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
cmake  \
-DBUILD_TESTING=OFF  \
-DDEVILUTIONX_SYSTEM_LIBFMT=OFF  \
-DCMAKE_OSX_ARCHITECTURES="x86_64" \
-DCMAKE_BUILD_TYPE=Release  \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7  \
..  \
-Wno-dev

cmake --build . --parallel $NCPU

cd ..

rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake  \
-DBUILD_TESTING=OFF  \
-DDEVILUTIONX_SYSTEM_LIBFMT=OFF  \
-DCMAKE_OSX_ARCHITECTURES="arm64" \
-DCMAKE_BUILD_TYPE=Release  \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.7  \
..  \
-Wno-dev

cmake --build . --parallel $NCPU

cd ..

export EXTRA_INFO_PLIST_ENTRIES="
    <key>CFBundleDisplayName</key>
	<string>DevilutionX</string>
    <key>SDL_FILESYSTEM_BASE_DIR_TYPE</key>
	<string>parent</string>"

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"