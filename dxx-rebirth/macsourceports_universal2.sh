# game/app specific values
export APP_VERSION="0.6.0"
export PROJECT_NAME="dxx-rebirth"
# because this project does two different app builds
# further game/app specific values are handled below

# constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="11.0"

# this port is not HiDPI aware
export HIGH_RESOLUTION_CAPABLE="false"

CROSS_FILE_DIR=$PWD

cd ../../${PROJECT_NAME}

# The music is MIDI, which SDL_mixer plays with FluidSynth, which needs a
# soundfont: point it at the music.sf2 bundled in each app (copied in below).
# Skip if it's already applied.
if ! git apply -R --check "${CROSS_FILE_DIR}/msp-soundfont.patch" 2>/dev/null; then
	git apply "${CROSS_FILE_DIR}/msp-soundfont.patch" || exit 1
fi

# Xcode 27's libc++ marks std::make_unique [[nodiscard]], so SConstruct's
# configure checks that discard its result fail under -Werror and the build
# reports "C++ compiler does not support std::make_unique". Skip if applied.
if ! git apply -R --check "${CROSS_FILE_DIR}/msp-xcode27-nodiscard.patch" 2>/dev/null; then
	git apply "${CROSS_FILE_DIR}/msp-xcode27-nodiscard.patch" || exit 1
fi

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}

# because this port does so much of the work itself all we need to do is 
# run the build command twice for the two platforms
rm -rf ${X86_64_BUILD_FOLDER}
scons PKG_CONFIG=/usr/local/bin/pkg-config opengl=1 sdlmixer=1 d1x=1 d2x=1 macos_add_frameworks=0 builddir=${X86_64_BUILD_FOLDER} --config=force CPPFLAGS="-mmacosx-version-min=${MINIMUM_SYSTEM_VERSION} -arch x86_64" CXXFLAGS="-mmacosx-version-min=${MINIMUM_SYSTEM_VERSION} -arch x86_64" LINKFLAGS="-mmacosx-version-min=${MINIMUM_SYSTEM_VERSION} -arch x86_64" -j$NCPU

rm -rf ${ARM64_BUILD_FOLDER}
scons PKG_CONFIG=/usr/local/bin/pkg-config opengl=1 sdlmixer=1 d1x=1 d2x=1 macos_add_frameworks=0 builddir=${ARM64_BUILD_FOLDER} --config=force CPPFLAGS="-mmacosx-version-min=${MINIMUM_SYSTEM_VERSION} -arch arm64" CXXFLAGS="-mmacosx-version-min=${MINIMUM_SYSTEM_VERSION} -arch arm64" LINKFLAGS="-mmacosx-version-min=${MINIMUM_SYSTEM_VERSION} -arch arm64" -j$NCPU

# descent1 values
export PRODUCT_NAME="D1X-Rebirth"
export ICONSFILENAME="d1x-rebirth"
export EXECUTABLE_NAME="d1x-rebirth"
export PKGINFO="APPLD1XR"

# have to re-do all the variables cascading down from PRODUCT_NAME
export WRAPPER_NAME="${PRODUCT_NAME}.app"
export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
export FRAMEWORKS_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Frameworks"
export ICONS="${ICONSFILENAME}.icns"

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cp "../../MSPBuildSystem/dxx-rebirth/music.sf2" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg (and don't clean up the build artifacts)
"../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"

# descent2 values
export PRODUCT_NAME="D2X-Rebirth"
export ICONSFILENAME="d2x-rebirth"
export EXECUTABLE_NAME="d2x-rebirth"
export PKGINFO="APPLD2XR"

# have to re-do all the variables cascading down from PRODUCT_NAME
export WRAPPER_NAME="${PRODUCT_NAME}.app"
export CONTENTS_FOLDER_PATH="${WRAPPER_NAME}/Contents"
export EXECUTABLE_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/MacOS"
export BUNDLE_ID="com.macsourceports.${PRODUCT_NAME}"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Resources"
export FRAMEWORKS_FOLDER_PATH="${CONTENTS_FOLDER_PATH}/Frameworks"
export ICONS="${ICONSFILENAME}.icns"

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

cd ${BUILT_PRODUCTS_DIR}
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}
cp "../../MSPBuildSystem/dxx-rebirth/music.sf2" "${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
cd ..

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg (and don't delete the previous one)
"../MSPBuildSystem/common/package_dmg.sh" "skipdelete"