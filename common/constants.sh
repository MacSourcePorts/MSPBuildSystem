# constants
export BUILT_PRODUCTS_DIR="release"
export WRAPPER_NAME="${PRODUCT_NAME}.app"
export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
export FRAMEWORKS_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Frameworks"
export ICONS="${ICONSFILENAME}.icns"
export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"
export HIGH_RESOLUTION_CAPABLE="false"

# For parallel make on multicore boxes...
export NCPU=`sysctl -n hw.ncpu`

export ARM64_BUILD_FOLDER="build-arm64"
export ARM64_LIBS_FOLDER="libs-arm64"

export X86_64_BUILD_FOLDER="build-x86_64"
export X86_64_LIBS_FOLDER="libs-x86_64"