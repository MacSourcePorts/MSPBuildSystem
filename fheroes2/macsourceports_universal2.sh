# game/app specific values
export APP_VERSION="1.1.1"
export PRODUCT_NAME="fheroes2"
export PROJECT_NAME="fheroes2"
export PORT_NAME="fheroes2"
export ICONSFILENAME="fheroes2"
export EXECUTABLE_NAME="fheroes2"
export PKGINFO="APPLFH2"
export GIT_TAG="1.1.1"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh
source ../common/signing_values.local

cd ../../${PROJECT_NAME}

if [ -n "$3" ]; then
	echo "Setting version / tag to : " "$3"
	export APP_VERSION="$3"
	export GIT_TAG="$3"
else
	echo "Leaving version / tag at : " "$APP_VERSION" / "$GIT_TAG"

	# because we do a patch, we need to reset any changes
	echo git reset --hard
	git reset --hard

	# reset to the main branch
	echo git checkout ${GIT_DEFAULT_BRANCH}
	git checkout ${GIT_DEFAULT_BRANCH}

	# fetch the latest 
	echo git pull
	git pull

	# check out the latest release tag
	echo git checkout tags/${GIT_TAG}
	git checkout tags/${GIT_TAG}
fi

rm -rf ${BUILT_PRODUCTS_DIR}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	patch CMakeLists.txt ../MSPBuildSystem/fheroes2/msp.diff
	mkdir ${BUILT_PRODUCTS_DIR}
	mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
	cd ${BUILT_PRODUCTS_DIR}
	cmake \
	-DMACOS_APP_BUNDLE=ON \
    -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
	..
    cmake --build . --parallel $NCPU
    # cp ${EXECUTABLE_NAME} ${EXECUTABLE_FOLDER_PATH}
    install_name_tool -add_rpath @executable_path/. ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
    "../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
	mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}/h2d
	cp ../files/data/resurrection.h2d ${UNLOCALIZED_RESOURCES_FOLDER_PATH}/h2d
	mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}/translations
	cp ../files/lang/*.mo ${UNLOCALIZED_RESOURCES_FOLDER_PATH}/translations
else
	rm -rf ${X86_64_BUILD_FOLDER}
	mkdir ${X86_64_BUILD_FOLDER}
	mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
	cd ${X86_64_BUILD_FOLDER}
	cmake \
	-DMACOS_APP_BUNDLE=ON \
	-DCMAKE_OSX_ARCHITECTURES=x86_64 \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
	-DCMAKE_PREFIX_PATH=/usr/local \
	-DCMAKE_INSTALL_PREFIX=/usr/local \
	..
	make -j$NCPU

	cd ..
	rm -rf ${ARM64_BUILD_FOLDER}
	mkdir ${ARM64_BUILD_FOLDER}
	mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
	cd ${ARM64_BUILD_FOLDER}
	cmake  \
	-DMACOS_APP_BUNDLE=ON \
	-DCMAKE_OSX_ARCHITECTURES=arm64 \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
	-DCMAKE_PREFIX_PATH=/opt/Homebrew \
	-DCMAKE_INSTALL_PREFIX=/opt/Homebrew \
	..
	make -j$NCPU
fi

cd ..

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
    "../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo" "skiplibs"
else
	"../MSPBuildSystem/common/build_app_bundle.sh"

	#create any app-specific directories
	if [ ! -d "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs" ]; then
		mkdir -p "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs" || exit 1;
	fi

	#lipo any app-specific things
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libmpg123.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libmpg123.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmpg123.0.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_mixer-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_mixer-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_mixer-2.0.0.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libSDL2-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2-2.0.0.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libxmp.4.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libxmp.4.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libxmp.4.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libFLAC.12.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libFLAC.12.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libFLAC.12.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libfluidsynth.3.2.2.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libfluidsynth.3.2.2.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libfluidsynth.3.2.2.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libglib-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libglib-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libglib-2.0.0.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libgthread-2.0.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libgthread-2.0.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libgthread-2.0.0.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libintl.8.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libintl.8.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libintl.8.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libmp3lame.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libmp3lame.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmp3lame.0.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libogg.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libogg.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libogg.0.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libopus.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libopus.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libopus.0.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libopusfile.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libopusfile.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libopusfile.0.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libpcre2-8.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libpcre2-8.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libpcre2-8.0.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libportaudio.2.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libportaudio.2.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libportaudio.2.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libreadline.8.2.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libreadline.8.2.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libreadline.8.2.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libsndfile.1.0.37.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libsndfile.1.0.37.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libsndfile.1.0.37.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libvorbis.0.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libvorbis.0.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libvorbis.0.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libvorbisenc.2.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libvorbisenc.2.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libvorbisenc.2.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libvorbisfile.3.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libvorbisfile.3.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libvorbisfile.3.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libgme.0.6.3.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libgme.0.6.3.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libgme.0.6.3.dylib" -create
	lipo ${X86_64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libwavpack.1.2.5.dylib ${ARM64_BUILD_FOLDER}/${CONTENTS_FOLDER_PATH}/libs/libwavpack.1.2.5.dylib -output "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libwavpack.1.2.5.dylib" -create

	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmpg123.0.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2_mixer-2.0.0.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libSDL2-2.0.0.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libxmp.4.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libFLAC.12.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libfluidsynth.3.2.2.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libglib-2.0.0.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libgthread-2.0.0.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libintl.8.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libmp3lame.0.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libogg.0.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libopus.0.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libopusfile.0.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libpcre2-8.0.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libportaudio.2.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libreadline.8.2.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libsndfile.1.0.37.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libvorbis.0.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libvorbisenc.2.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libvorbisfile.3.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libgme.0.6.3.dylib
	codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" ${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/libs/libwavpack.1.2.5.dylib
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"