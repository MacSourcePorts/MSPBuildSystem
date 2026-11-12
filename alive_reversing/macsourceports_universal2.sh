# game/app specific values
export APP_VERSION="1.1.0"
export PRODUCT_NAME="relive"
export PROJECT_NAME="alive_reversing"
export PORT_NAME="R.E.L.I.V.E."
export ICONSFILENAME="oddworld-ae"
export EXECUTABLE_NAME="relive"
export PKGINFO="APPLOWAE"

# constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.15"

CROSS_FILE_DIR=$PWD

cd ../../${PROJECT_NAME}

# release tags look like github-v1.1.0
if [ -n "$2" ]; then
	export APP_VERSION="${2#github-v}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

# Run from ~/Library/Application Support/Oddworld/AO or AE instead of from
# inside the app bundle -- see the patch. Skip if it's already applied.
if ! git apply -R --check "${CROSS_FILE_DIR}/msp-appsupport.patch" 2>/dev/null; then
	git apply "${CROSS_FILE_DIR}/msp-appsupport.patch"
fi

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}
cd ${BUILT_PRODUCTS_DIR}
# options.cmake runs as a separate "cmake -P" during the build and does not see -D flags
export CMAKE_POLICY_VERSION_MINIMUM=3.5
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
-DCMAKE_PREFIX_PATH=/usr/local \
-DCMAKE_INSTALL_PREFIX=/usr/local \
-DCMAKE=/usr/local/bin/cmake \
-DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
-DCMAKE_C_FLAGS="-Wno-error=single-bit-bitfield-constant-conversion -Wno-error=unused-but-set-variable" \
..
cmake --build . --parallel $NCPU
cd ..

# One build, two apps. Each app's executable is named for its game
# (relive-AO / relive-AE): the patched startup code picks that game's
# Application Support folder from the name, and relive itself starts AO when
# "AO" is on its command line, which includes the executable's path.
package_game() {
	export PRODUCT_NAME="relive-$1"
	export PORT_NAME="R.E.L.I.V.E. $2"
	export ICONSFILENAME="$3"
	export PKGINFO="$4"
	export EXECUTABLE_NAME="relive-$2"

	# have to re-do all the variables cascading down from PRODUCT_NAME
	export WRAPPER_NAME="${PRODUCT_NAME}.app"
	export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
	export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
	export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
	export FRAMEWORKS_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Frameworks"
	export ICONS="${ICONSFILENAME}.icns"
	export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"

	mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
	cp ${BUILT_PRODUCTS_DIR}/Source/relive/relive ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
	(cd ${BUILT_PRODUCTS_DIR} && "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH})

	# create the app bundle
	"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

	# sign and notarize
	"../MSPBuildSystem/common/sign_and_notarize.sh" "$5"
}

package_game ao AO oddworld-ao APPLOWAO "$1"
# create dmg -- keep the build folder for the second app
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"

package_game ae AE oddworld-ae APPLOWAE "$1"
# create dmg -- same release folder as the first
"../MSPBuildSystem/common/package_dmg.sh" "skipdelete"
