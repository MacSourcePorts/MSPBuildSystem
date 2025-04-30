# game/app specific values
export APP_VERSION="1.2.0"
export PRODUCT_NAME="Gardens of Kadesh"
export PROJECT_NAME="gardens-of-kadesh"
export PORT_NAME="gardens-of-kadesh"
export ICONSFILENAME="gardens-of-kadesh"
export EXECUTABLE_NAME="Homeworld"
export PKGINFO="APPLGOFK"
export GIT_DEFAULT_BRANCH="master"
export GIT_TAG="1.2.0"

# constants
source ../common/constants.sh
source ../common/signing_values.local

cd ../../${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

# check out the latest release tag
# echo git checkout tags/${GIT_TAG}
# git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}

# xcodebuild will make the release folder for us
xcodebuild \
	-project Mac/Homeworld.xcodeproj \
	-scheme "Homeworld" \
	-configuration Release \
	-arch x86_64 -arch arm64 \
	clean \
	build \
	-verbose \
	INFOPLIST_FILE=Homeworld.plist \
	GCC_PREPROCESSOR_DEFINITIONS='HW_BUILD_FOR_DEBUGGING HW_GAME_HOMEWORLD _X86_64_FIX_ME _X86_64 _MACOSX BF_HOMEWORLD'  \
	CLANG_WARN_IMPLICIT_FUNCTION_DECLARATIONS=NO \
	GCC_TREAT_WARNINGS_AS_ERRORS=NO \
	CLANG_TREAT_WARNINGS_AS_ERRORS=NO \
	GCC_PREFIX_HEADER=Homeworld_Prefix.h \
	CODE_SIGNING_ALLOWED="NO" \
	WRAPPER_NAME=Homeworld.app \
	EXECUTABLE_NAME=Homeworld \
	SYMROOT=$PWD/${BUILT_PRODUCTS_DIR}

echo $PWD
echo mv ${BUILT_PRODUCTS_DIR}/Default/Homeworld.app "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
mv ${BUILT_PRODUCTS_DIR}/Default/Homeworld.app "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

# #sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# #create dmg
"../MSPBuildSystem/common/package_dmg.sh"