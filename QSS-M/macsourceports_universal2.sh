# game/app specific values
export APP_VERSION="1.6.5"
export PRODUCT_NAME="QSS-M"
export PROJECT_NAME="QSS-M"
export PORT_NAME="QSS-M"
export ICONSFILENAME="QSS-M"
export EXECUTABLE_NAME="QSS-M"

# constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="12.0"

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

cd macOS
# Xcode 27 won't build for anything below macOS 12.0, and the xcodebuild call lives in QSS-M's own script
if ! grep -q "MACOSX_DEPLOYMENT_TARGET" build-macos.sh; then
	gsed -i 's|^xcodebuild -project QuakeSpasm.xcodeproj -target QSS-M$|& MACOSX_DEPLOYMENT_TARGET=12.0|' build-macos.sh
fi
# overwrite SDKROOT to keep script's nettle happy
export SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
./build-macos.sh
cd ..

mv "macOS/build/Release/QSS-M.app" "${BUILT_PRODUCTS_DIR}"

"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"