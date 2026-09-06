# game/app specific values
export APP_VERSION="1.6.5"
export PRODUCT_NAME="QSS-M"
export PROJECT_NAME="QSS-M"
export PORT_NAME="QSS-M"
export ICONSFILENAME="QSS-M"
export EXECUTABLE_NAME="QSS-M"

# constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.13"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at: $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}

# This one has a script that does most of the work
# Note that this folder gets renamed to "macOS" after 1.6.5 sometime

cd MacOSX
./build-macos.sh
cd ..

mv "MacOSX/build/Release/QSS-M.app" "${BUILT_PRODUCTS_DIR}"

"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"