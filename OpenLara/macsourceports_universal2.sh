## TODO!!
## TODO!!
## TODO!!

## Make things go to the right directories!
## Until then make a copy of what Xcode releases, put it in the folder with this script, zip it up, then run it. Then delete that app and zip.

## TODO!!
## TODO!!
## TODO!!

# game/app specific values
export APP_VERSION="1.0"
export PRODUCT_NAME="OpenLara"
export PROJECT_NAME="OpenLara"
export PORT_NAME="OpenLara"
export ICONSFILENAME="OpenLara"
export EXECUTABLE_NAME="OpenLara"

# constants
source ../common/constants.sh
source ../common/signing_values.local

export BUILT_PRODUCTS_DIR="release"
export WRAPPER_NAME="OpenLara.app"
export CONTENTS_FOLDER_PATH="OpenLara.app/Contents"
export EXECUTABLE_FOLDER_PATH="OpenLara.app/Contents/MacOS"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="OpenLara.app/Contents/Resources"
export FRAMEWORKS_FOLDER_PATH="OpenLara.app/Contents/Frameworks"
export BUNDLE_ID="com.macsourceports.OpenLara"
export HIGH_RESOLUTION_CAPABLE="true"

# Pre-notarized zip file (not what is shipped)
PRE_NOTARIZED_ZIP="${PRODUCT_NAME}_prenotarized.zip"

# Post-notarized zip file (shipped)
POST_NOTARIZED_ZIP="${PRODUCT_NAME}_notarized_$(date +"%Y-%m-%d").zip"


# dylibbundler -od -b -x "./OpenLara.app/Contents/MacOS/OpenLara" -d "./OpenLara.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/

if [ -d "./OpenLara.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/" ]; then
rm -rf "./OpenLara.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/" || exit 1;
fi
mkdir -p "./OpenLara.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/";
echo cp /usr/local/opt/fluid-synth/lib/libfluidsynth.3.dylib "./OpenLara.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/"
cp /usr/local/opt/fluid-synth/lib/libfluidsynth.3.dylib "./OpenLara.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/"

if [ -d "./OpenLara.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/" ]; then
rm -rf "./OpenLara.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/" || exit 1;
fi
mkdir -p "./OpenLara.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/";
echo cp /opt/homebrew/opt/fluid-synth/lib/libfluidsynth.3.dylib "./OpenLara.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/"
cp /opt/homebrew/opt/fluid-synth/lib/libfluidsynth.3.dylib "./OpenLara.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/"

install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/libz.1.dylib OpenLara.app/Contents/MacOS/OpenLara
install_name_tool -change /opt/local/lib/libpng16.16.dylib @executable_path/libpng16.16.dylib OpenLara.app/Contents/MacOS/OpenLara
install_name_tool -change /opt/local/lib/libSDL2_net-2.0.0.dylib @executable_path/libSDL2_net-2.0.0.dylib OpenLara.app/Contents/MacOS/OpenLara
install_name_tool -change /opt/local/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib OpenLara.app/Contents/MacOS/OpenLara
install_name_tool -change /usr/local/opt/fluid-synth/lib/libfluidsynth.3.dylib @executable_path/${X86_64_LIBS_FOLDER}/libfluidsynth.3.dylib OpenLara.app/Contents/MacOS/OpenLara
install_name_tool -change /opt/homebrew/opt/fluid-synth/lib/libfluidsynth.3.dylib @executable_path/${ARM64_LIBS_FOLDER}/libfluidsynth.3.dylib OpenLara.app/Contents/MacOS/OpenLara

dylibbundler -b -x "./OpenLara.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/libfluidsynth.3.dylib" -d "./OpenLara.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
dylibbundler -b -x "./OpenLara.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/libfluidsynth.3.dylib" -d "./OpenLara.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/

codesign --force --options runtime --deep --sign "${SIGNING_IDENTITY}" OpenLara.app

if [ "$1" == "notarize" ]; then

	# notarize app

	# create the zip to send to the notarization service
	echo "zipping..."
	echo ditto -c -k --sequesterRsrc --keepParent "OpenLara.app" "${PRE_NOTARIZED_ZIP}"
	ditto -c -k --sequesterRsrc --keepParent "OpenLara.app" "${PRE_NOTARIZED_ZIP}"

	# submit app for notarization
	echo "submitting..."
	xcrun notarytool submit "$PRE_NOTARIZED_ZIP" --wait --key "../common/${AUTH_KEY_FILENAME}" --key-id "${AUTH_KEY_ID}" --issuer "${AUTH_KEY_ISSUER_ID}"

	# once notarization is complete, run stapler and exit
	echo "stapling..."
	xcrun stapler staple OpenLara.app

	echo "notarized"
	echo "zipping notarized..."

	ditto -c -k --sequesterRsrc --keepParent OpenLara.app "${POST_NOTARIZED_ZIP}"

	echo "done. ${POST_NOTARIZED_ZIP} contains notarized OpenLara.app build."
fi



#move app bundle to a subfolder
mkdir -p source_folder
mv "${WRAPPER_NAME}" source_folder

#create DMG from that subfolder
create-dmg \
  --volname "${PORT_NAME}" \
  --volicon "../common/msp_dmg.icns" \
  --background "../common/msp_dmg_background.tiff" \
  --window-pos 200 120 \
  --window-size 750 400 \
  --icon-size 100 \
  --icon "${WRAPPER_NAME}" 175 190 \
  --hide-extension "${WRAPPER_NAME}" \
  --app-drop-link 575 185 \
  --no-internet-enable \
  "${PRODUCT_NAME}-${APP_VERSION}${ARCH_SUFFIX}.dmg" \
  "source_folder"

#move app bundle back to parent folder
echo mv "source_folder/${WRAPPER_NAME}" .
mv "source_folder/${WRAPPER_NAME}" .
rm -rd source_folder

if [ -d "release-${APP_VERSION}${ARCH_FOLDER}" ]; then
rm -rf "release-${APP_VERSION}${ARCH_FOLDER}" || exit 1;
fi
mkdir -p "release-${APP_VERSION}${ARCH_FOLDER}";

cp -a "${PRODUCT_NAME}-${APP_VERSION}${ARCH_SUFFIX}.dmg" "release-${APP_VERSION}${ARCH_FOLDER}"