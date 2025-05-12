# game/app specific values
export APP_VERSION="0.89-BF"
export PRODUCT_NAME="Selaco"
export PROJECT_NAME="Selaco"
export PORT_NAME="Selaco"
export ICONSFILENAME="selaco"
export EXECUTABLE_NAME="Selaco"
export PKGINFO="APPLGZSL"
export GIT_TAG="v0.89-BF"
export GIT_DEFAULT_BRANCH="macos/0.89-BF"
export ENTITLEMENTS_FILE="../MSPBuildSystem/selaco/selaco.entitlements"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

if [ "$1" == "buildserver" ] || [ "$2" == "buildserver" ]; then
	echo "Skipping git because we're on the build server"

    # reset to the main branch
    echo git checkout ${GIT_DEFAULT_BRANCH}
    git checkout ${GIT_DEFAULT_BRANCH}
else
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
    # echo git checkout tags/${GIT_TAG}
    # git checkout tags/${GIT_TAG}
fi

rm -rf ${BUILT_PRODUCTS_DIR}

#because this port does so much of the packaging itself all we need to do is run the script
gsed -i 's|opt|usr|' "build_osx.sh"
gsed -i 's|opt|usr|' "build_osx.sh"
gsed -i 's|opt|usr|' "build_osx.sh"
gsed -i 's| build| release|' "build_osx.sh"
install_name_tool -change /opt/local/lib/libglib-2.0.0.dylib /usr/local/lib/libglib-2.0.0.dylib bin/osx/zmusic/lib/libzmusic.1.1.14.dylib
install_name_tool -change /opt/local/lib/libglib-2.0.0.dylib /usr/local/lib/libglib-2.0.0.dylib bin/osx/zmusic/lib/libzmusiclite.1.1.14.dylib

./build_osx.sh

cp /usr/local/lib/libintl.8.dylib release/Selaco.app/Contents/Frameworks 
cp /usr/local/lib/libpcre2-8.0.dylib release/Selaco.app/Contents/Frameworks
cp /usr/local/lib/libvorbis.0.4.9.dylib release/Selaco.app/Contents/Frameworks
cp /usr/local/lib/libogg.0.dylib release/Selaco.app/Contents/Frameworks
cp /usr/local/lib/libmp3lame.0.dylib release/Selaco.app/Contents/Frameworks
cp /usr/local/lib/libopus.0.dylib release/Selaco.app/Contents/Frameworks
cp /usr/local/lib/libFLAC.12.dylib release/Selaco.app/Contents/Frameworks
cp /usr/local/lib/libmpg123.0.dylib release/Selaco.app/Contents/Frameworks
cp /usr/local/lib/libvorbisenc.2.0.12.dylib release/Selaco.app/Contents/Frameworks

gsed -i 's|org.drdteam.gzdoom|com.macsourceports.selaco|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"
gsed -i 's|Development Version|0.89-BF|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

echo rm "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}";
rm "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}";
echo cp "${ICONSDIR}/${ICONS}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}" || exit 1;
cp "${ICONSDIR}/${ICONS}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}" || exit 1;

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"