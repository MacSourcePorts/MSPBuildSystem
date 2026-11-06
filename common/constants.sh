# constants
export BUILT_PRODUCTS_DIR="release"
export WRAPPER_NAME="${PRODUCT_NAME}.app"
export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
export FRAMEWORKS_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Frameworks"
export ICONSDIR="../MSPBuildSystem/${PROJECT_NAME}"
export ICONS="${ICONSFILENAME}.icns"
export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"
export HIGH_RESOLUTION_CAPABLE="true"
export MINIMUM_SYSTEM_VERSION="10.7"

# For parallel make on multicore boxes...
export NCPU=`sysctl -n hw.ncpu`

export ARM64_BUILD_FOLDER="build-arm64"
export ARM64_LIBS_FOLDER="libs-arm64"

export X86_64_BUILD_FOLDER="build-x86_64"
export X86_64_LIBS_FOLDER="libs-x86_64"

export DATE_TIMESTAMP="$(date +'%Y-%m-%d')"

export VULKAN_SDK_VERSION="1.4.357.1"

# Latest-code builds: Buildbot passes the build's date (YYYYMMDD) so the
# version -- and with it the DMG name and the Info.plist version keys --
# becomes e.g. 0.20-20261030. Unset for everything else.
if [ -n "${MSP_VERSION_DATE}" ]; then
	export APP_VERSION="${APP_VERSION}-${MSP_VERSION_DATE}"
	echo "Dated version: ${APP_VERSION}"
fi

set -e