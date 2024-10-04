# game/app specific values
export APP_VERSION="8.41"
export PRODUCT_NAME="yquake2"
export PROJECT_NAME="yquake2"
export PORT_NAME="Yamagi Quake II"
export ICONSFILENAME="quake2"
export EXECUTABLE_NAME="quake2"
export PKGINFO="APPLGYQ2"
export GIT_TAG="QUAKE2_8_41"
export GIT_DEFAULT_BRANCH="master"
export GIT_TAG_XATRIX="XATRIX_2_13"
export GIT_TAG_ROGUE="ROGUE_2_12"
export GIT_TAG_CTF="CTF_1_10"

# constants
source ../common/constants.sh

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	ARM64_CFLAGS="-mmacosx-version-min=10.7"
	ARM64_LDFLAGS="-mmacosx-version-min=10.7"
	x86_64_CFLAGS="-mmacosx-version-min=10.7"
	x86_64_LDFLAGS="-mmacosx-version-min=10.7"
else
	ARM64_CFLAGS="-I/opt/homebrew/include -I/opt/homebrew/opt/openal-soft/include -mmacosx-version-min=10.7"
	ARM64_LDFLAGS="-L/opt/homebrew/lib -L/opt/homebrew/opt/openal-soft/lib -mmacosx-version-min=10.7"
	x86_64_CFLAGS="-mmacosx-version-min=10.7"
	x86_64_LDFLAGS="-mmacosx-version-min=10.7"
fi

# Command line arguments:
# $3: yquake2 tag
# $4: xatrix tag
# $5: rogue tag
# $6: ctf tag

# build the expansion pack libraries first

# Mission Pack 1: The Reckoning (XATRIX)
cd ../../xatrix

if [ -n "$4" ]; then
	export GIT_TAG_XATRIX="$4"
	echo "Setting Xatrix (mp1) tag to: " "$GIT_TAG_XATRIX"
else
	# reset to the main branch
	echo git checkout ${GIT_DEFAULT_BRANCH}
	git checkout ${GIT_DEFAULT_BRANCH}

	# fetch the latest 
	echo git pull
	git pull

	# check out the latest release tag
	echo git checkout tags/${GIT_TAG_XATRIX}
	git checkout tags/${GIT_TAG_XATRIX}
fi 

(YQ2_ARCH=x86_64 make clean) || exit 1;
(YQ2_ARCH=x86_64 CFLAGS=$x86_64_CFLAGS  LDFLAGS=$x86_64_LDFLAGS make -j$NCPU) || exit 1;
mkdir -p ${X86_64_BUILD_FOLDER}
mv release/* ${X86_64_BUILD_FOLDER}
rm -rd release

(YQ2_ARCH=arm64 make clean) || exit 1;
(YQ2_ARCH=arm64 CFLAGS=$ARM64_CFLAGS  LDFLAGS=$ARM64_LDFLAGS make -j$NCPU) || exit 1;
mkdir -p ${ARM64_BUILD_FOLDER}
mv release/* ${ARM64_BUILD_FOLDER}
rm -rd release

# Mission Pack 2: Ground Zero (ROGUE)
cd ../rogue

if [ -n "$5" ]; then
	export GIT_TAG_ROGUE="$5"
	echo "Setting Rogue (mp2) tag to: " "$GIT_TAG_ROGUE"
else
	# reset to the main branch
	echo git checkout ${GIT_DEFAULT_BRANCH}
	git checkout ${GIT_DEFAULT_BRANCH}

	# fetch the latest 
	echo git pull
	git pull

	# check out the latest release tag
	echo git checkout tags/${GIT_TAG_ROGUE}
	git checkout tags/${GIT_TAG_ROGUE}
fi

(YQ2_ARCH=x86_64 make clean) || exit 1;
(YQ2_ARCH=x86_64 CFLAGS=$x86_64_CFLAGS  LDFLAGS=$x86_64_LDFLAGS make -j$NCPU) || exit 1;
mkdir -p ${X86_64_BUILD_FOLDER}
mv release/* ${X86_64_BUILD_FOLDER}
rm -rd release

(YQ2_ARCH=arm64 make clean) || exit 1;
(YQ2_ARCH=arm64 CFLAGS=$ARM64_CFLAGS  LDFLAGS=$ARM64_LDFLAGS make -j$NCPU) || exit 1;
mkdir -p ${ARM64_BUILD_FOLDER}
mv release/* ${ARM64_BUILD_FOLDER}
rm -rd release

# ThreeWave Capture the Flag (CTF)
cd ../ctf

if [ -n "$6" ]; then
	export GIT_TAG_CTF="$6"
	echo "Setting CTF tag to: " "$GIT_TAG_CTF"
else
	# reset to the main branch
	echo git checkout ${GIT_DEFAULT_BRANCH}
	git checkout ${GIT_DEFAULT_BRANCH}

	# fetch the latest 
	echo git pull
	git pull

	# check out the latest release tag
	echo git checkout tags/${GIT_TAG_CTF}
	git checkout tags/${GIT_TAG_CTF}
fi

(YQ2_ARCH=x86_64 make clean) || exit 1;
(YQ2_ARCH=x86_64 CFLAGS=$x86_64_CFLAGS  LDFLAGS=$x86_64_LDFLAGS make -j$NCPU) || exit 1;
mkdir -p ${X86_64_BUILD_FOLDER}
mv release/* ${X86_64_BUILD_FOLDER}
rm -rd release

(YQ2_ARCH=arm64 make clean) || exit 1;
(YQ2_ARCH=arm64 CFLAGS=$ARM64_CFLAGS  LDFLAGS=$ARM64_LDFLAGS make -j$NCPU) || exit 1;
mkdir -p ${ARM64_BUILD_FOLDER}
mv release/* ${ARM64_BUILD_FOLDER}
rm -rd release

# Main game compilation
cd ../${PROJECT_NAME}

if [ -n "$3" ]; then
	# turns QUAKE2_8_41 into 8.41
	export APP_VERSION="${3/QUAKE2_/}"
	export APP_VERSION="${APP_VERSION/_/.}"
	export GIT_TAG="$3"
	echo "Setting yquake2 version / tag to : " "$APP_VERSION" / "$GIT_TAG"
else
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
rm -rf ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}

(YQ2_ARCH=x86_64 make clean) || exit 1;
(YQ2_ARCH=x86_64 CFLAGS=$x86_64_CFLAGS  LDFLAGS=$x86_64_LDFLAGS make -j$NCPU) || exit 1;
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mv release/* ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
rm -rd release

(YQ2_ARCH=arm64 make clean) || exit 1;
(YQ2_ARCH=arm64 CFLAGS=$ARM64_CFLAGS  LDFLAGS=$ARM64_LDFLAGS make -j$NCPU) || exit 1;
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mv release/* ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
rm -rd release

# create the app bundle
if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	"../MSPBuildSystem/common/build_app_bundle.sh" "skiplibs"
else 
	"../MSPBuildSystem/common/build_app_bundle.sh"
	#dylibbundler the quake2 libs
	dylibbundler -od -b -x ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl1.dylib -d ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/ -p @executable_path/${X86_64_LIBS_FOLDER}/
	dylibbundler -od -b -x ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl3.dylib -d ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/ -p @executable_path/${X86_64_LIBS_FOLDER}/
	dylibbundler -od -b -x ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_soft.dylib -d ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/ -p @executable_path/${X86_64_LIBS_FOLDER}/
	dylibbundler -od -b -x ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/baseq2/game.dylib -d ./${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/ -p @executable_path/${X86_64_LIBS_FOLDER}/
	dylibbundler -od -b -x ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl1.dylib -d ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/ -p @executable_path/${ARM64_LIBS_FOLDER}/
	dylibbundler -od -b -x ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl3.dylib -d ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/ -p @executable_path/${ARM64_LIBS_FOLDER}/
	dylibbundler -od -b -x ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_soft.dylib -d ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/ -p @executable_path/${ARM64_LIBS_FOLDER}/
	dylibbundler -od -b -x ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/baseq2/game.dylib -d ./${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/ -p @executable_path/${ARM64_LIBS_FOLDER}/
fi

#create any app-specific directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/baseq2" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/baseq2" || exit 1;
fi

if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/xatrix" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/xatrix" || exit 1;
fi

if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/rogue" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/rogue" || exit 1;
fi

if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ctf" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ctf" || exit 1;
fi

#lipo any app-specific things
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl1.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl1.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_gl1.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl3.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_gl3.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_gl3.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_soft.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/ref_soft.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ref_soft.dylib" -create
lipo ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/baseq2/game.dylib ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/baseq2/game.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/baseq2/game.dylib" -create
lipo ../xatrix/${X86_64_BUILD_FOLDER}/game.dylib ../xatrix/${ARM64_BUILD_FOLDER}/game.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/xatrix/game.dylib" -create
lipo ../rogue/${X86_64_BUILD_FOLDER}/game.dylib ../rogue/${ARM64_BUILD_FOLDER}/game.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/rogue/game.dylib" -create
lipo ../ctf/${X86_64_BUILD_FOLDER}/game.dylib ../ctf/${ARM64_BUILD_FOLDER}/game.dylib -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/ctf/game.dylib" -create

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	cd ${BUILT_PRODUCTS_DIR}
    install_name_tool -add_rpath @executable_path/. "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
    "../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}"
    "../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/ref_gl1.dylib"
    "../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/ref_gl3.dylib"
    "../../MSPBuildSystem/common/copy_dependencies.sh" "${EXECUTABLE_FOLDER_PATH}/ref_soft.dylib"
	cd ..
fi

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"