# game/app specific values
# civctp2 has no version numbers of its own (its releases are named by date,
# e.g. "Apolyton Edition 2025-01-20"): dated builds are just the date
# (20261119, see constants.sh); a build without one is still called 1.0
if [ -n "${MSP_VERSION_DATE}" ]; then
	export APP_VERSION=""
else
	export APP_VERSION="1.0"
fi
export PRODUCT_NAME="civctp2"
export PROJECT_NAME="civctp2"
export PORT_NAME="Call to Power II"
export ICONSFILENAME="civctp2"
export EXECUTABLE_NAME="ctp2"
export PKGINFO="APPLCTP2"

# constants
source ../common/constants.sh
source ../common/signing_values.local
# the /usr/local libraries it links against (SDL2 etc.) are 11.0+
export MINIMUM_SYSTEM_VERSION="11.0"
export MACOSX_DEPLOYMENT_TARGET=${MINIMUM_SYSTEM_VERSION}

# byacc and the autotools come from /usr/local (see libraries/byacc.sh)
export PATH="/usr/local/bin:$PATH"

PATCH_DIR=$PWD

cd ../../${PROJECT_NAME}

# macOS support: the macOS build target, POSIX code paths, clang fixes, and
# the game data in ~/Library/Application Support/civctp2 -- see the patch.
# Skip if it's already applied.
if ! git apply -R --check "${PATCH_DIR}/msp-macos.patch" 2>/dev/null; then
	git apply "${PATCH_DIR}/msp-macos.patch"
fi

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}

# autotools build, in the source tree (the executable lands in ctp2_code/ctp)
./autogen.sh

# C is pinned to C17: clang now defaults to C23, which rejects the K&R
# function definitions in anet and freetype 1.3. va_arg(MapPoint) is fine
# (MapPoint is trivially copyable) but clang errors on it by default.
# FFmpeg movies: without them the intro shows a black screen until clicked.
./configure \
	CC="clang -arch arm64 -arch x86_64" \
	CXX="clang++ -arch arm64 -arch x86_64" \
	CPP="clang -E" CXXCPP="clang++ -E" \
	CFLAGS="-O2 -std=gnu17" \
	CXXFLAGS="-O2 -Wno-non-pod-varargs" \
	CPPFLAGS="-I/usr/local/include" \
	LDFLAGS="-L/usr/local/lib" \
	--enable-silent-rules \
	--enable-ffmpeg4movies

# the first parallel make can trip over generated files (see the README)
make -j$NCPU || make

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"
cp ctp2_code/ctp/${EXECUTABLE_NAME} "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"

# runtime files the game wants beside its executable (copied into the user's
# data folder on launch), and the map generator plugins (loaded from here)
RESOURCES="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
mkdir -p "${RESOURCES}/ctp2_code/ctp/dll/map"
cp ctp2_code/ctp/civpaths.txt ctp2_code/ctp/appstr.txt ctp2_code/ctp/anet.inf ctp2_code/ctp/bootserv.txt "${RESOURCES}/ctp2_code/ctp"
cp ctp2_code/ctp/dll/map/*.so "${RESOURCES}/ctp2_code/ctp/dll/map"

# the Apolyton data and scenario changes, used on top of the original game's
ditto ctp2_data "${RESOURCES}/ctp2_data"
ditto Scenarios "${RESOURCES}/Scenarios"

# bundle the /usr/local libraries
cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cd ..

# codesign --deep doesn't reach code in Resources, so sign the plugins here
for plugin in "${RESOURCES}"/ctp2_code/ctp/dll/map/*.so; do
	codesign --force --options runtime --timestamp --sign "${SIGNING_IDENTITY}" "$plugin"
done

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"
