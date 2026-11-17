# game/app specific values
export APP_VERSION="1.6"
export PRODUCT_NAME="openxray"
export PROJECT_NAME="xray-16"
export PORT_NAME="OpenXRay"
export ICONSFILENAME="openxray"
export EXECUTABLE_NAME="xr_3da"
export PKGINFO="APPLOPXR"

# constants
source ../common/constants.sh
# the /usr/local libraries it links against are 11.0+
export MINIMUM_SYSTEM_VERSION="11.0"

CROSS_FILE_DIR=$PWD

cd ../../${PROJECT_NAME}

# LuaJIT's build detected the build machine's CPU rather than the target's, so
# an x86_64 build on Apple Silicon got an arm64 interpreter -- the reason the
# Intel build never worked. Skip if it's already applied.
if ! git apply -R --check "${CROSS_FILE_DIR}/msp-luajit-cross.patch" 2>/dev/null; then
	git apply "${CROSS_FILE_DIR}/msp-luajit-cross.patch" || exit 1
fi

# The game links fsgame.ltx and the OpenGL shaders into its data folder
# (~/Library/Application Support/GSC Game World/<game>/) from an install
# folder; point that at the app's Resources, where they're bundled below.
if ! git apply -R --check "${CROSS_FILE_DIR}/msp-bundle-resources.patch" 2>/dev/null; then
	git apply "${CROSS_FILE_DIR}/msp-bundle-resources.patch" || exit 1
fi

# the build puts everything in a top-level bin/<arch>/Release folder
rm -rf bin
rm -rf ${BUILT_PRODUCTS_DIR}
rm -rf ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}

# one build per architecture: the code and LuaJIT are CPU-specific
for ARCH in x86_64 arm64; do
	BUILD_FOLDER="build-${ARCH}"
	mkdir ${BUILD_FOLDER}
	cd ${BUILD_FOLDER}
	cmake \
	-DCMAKE_TOOLCHAIN_FILE="${CROSS_FILE_DIR}/${ARCH}.cmake" \
	-DCMAKE_OSX_ARCHITECTURES=${ARCH} \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION} \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_PREFIX_PATH=/usr/local \
	-DCMAKE_FIND_FRAMEWORK=LAST \
	.. || exit 1
	cmake --build . -j $NCPU || exit 1
	cd ..
done

# create the app bundle (the executable is lipo'd below, with the libraries)
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

# lipo the executable and the engine's libraries together
mkdir -p "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
for f in bin/arm64/Release/${EXECUTABLE_NAME} bin/arm64/Release/*.dylib; do
	name=$(basename "$f")
	if [ "$name" = "${EXECUTABLE_NAME}" ]; then
		dest="${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${name}"
	else
		dest="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/${name}"
	fi
	# drop the build-machine rpaths (the build folder and /usr/local/lib),
	# which differ per architecture, before lipo'ing
	for thin in "bin/x86_64/Release/${name}" "$f"; do
		for rpath in $(otool -l "$thin" | awk '/cmd LC_RPATH/{getline; getline; print $2}' | sort -u); do
			install_name_tool -delete_rpath "$rpath" "$thin" || exit 1
		done
	done
	lipo "bin/x86_64/Release/${name}" "$f" -output "$dest" -create || exit 1
done

# bundle the /usr/local libraries the executable and engine libraries use
cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
for lib in ${FRAMEWORKS_FOLDER_PATH}/xr*.dylib; do
	"../../MSPBuildSystem/common/copy_dependencies.sh" "$lib" ${FRAMEWORKS_FOLDER_PATH}
done
cd ..

# fsgame.ltx and the OpenXRay gamedata (shaders etc.), found via
# msp-bundle-resources.patch
mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/openxray"
cp res/fsgame.ltx "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/openxray"
cp -R res/gamedata "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/openxray"

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
