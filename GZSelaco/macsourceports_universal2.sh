# game/app specific values
export APP_VERSION="0.92a"
export PRODUCT_NAME="GZSelaco"
export PROJECT_NAME="GZSelaco"
export PORT_NAME="GZSelaco"
export ICONSFILENAME="GZSelaco"
export EXECUTABLE_NAME="Selaco"
export PKGINFO="APPLGZSL"
export ENTITLEMENTS_FILE="../MSPBuildSystem/GZSelaco/GZSelaco.entitlements"

#constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.15"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

rm -rf ${BUILT_PRODUCTS_DIR}

#because this port does so much of the packaging itself all we need to do is run the script
gsed -i 's|opt|usr|' "build_osx.sh"
gsed -i 's|opt|usr|' "build_osx.sh"
gsed -i 's|opt|usr|' "build_osx.sh"
gsed -i 's| build| release|' "build_osx.sh"
gsed -i 's|-DCMAKE_BUILD_TYPE=Release|-DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5|' build_osx.sh
install_name_tool -change /opt/local/lib/libglib-2.0.0.dylib /usr/local/lib/libglib-2.0.0.dylib bin/osx/zmusic/lib/libzmusic.1.1.14.dylib
install_name_tool -change /opt/local/lib/libglib-2.0.0.dylib /usr/local/lib/libglib-2.0.0.dylib bin/osx/zmusic/lib/libzmusiclite.1.1.14.dylib

./build_osx.sh

mv release/Selaco.app release/GZSelaco.app

cp /usr/local/lib/libintl.8.dylib release/GZSelaco.app/Contents/Frameworks 
cp /usr/local/lib/libpcre2-8.0.dylib release/GZSelaco.app/Contents/Frameworks
cp /usr/local/lib/libvorbis.0.4.9.dylib release/GZSelaco.app/Contents/Frameworks
cp /usr/local/lib/libogg.0.dylib release/GZSelaco.app/Contents/Frameworks
cp /usr/local/lib/libmp3lame.0.dylib release/GZSelaco.app/Contents/Frameworks
cp /usr/local/lib/libopus.0.dylib release/GZSelaco.app/Contents/Frameworks
cp /usr/local/lib/libFLAC.12.dylib release/GZSelaco.app/Contents/Frameworks
cp /usr/local/lib/libmpg123.0.dylib release/GZSelaco.app/Contents/Frameworks
cp /usr/local/lib/libvorbisenc.2.0.12.dylib release/GZSelaco.app/Contents/Frameworks

gsed -i 's|org.drdteam.gzdoom|com.macsourceports.gzselaco|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"
gsed -i 's|0.90|0.92a|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"
gsed -i 's|selaco.icns|GZSelaco.icns|' "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

echo rm "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Selaco.icns";
rm "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Selaco.icns";
echo cp "${ICONSDIR}/${ICONS}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}" || exit 1;
cp "${ICONSDIR}/${ICONS}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}" || exit 1;

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"