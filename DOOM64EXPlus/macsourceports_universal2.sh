# game/app specific values
export APP_VERSION="3.6.5.8"
export PRODUCT_NAME="DOOM64EXPlus"
export PROJECT_NAME="DOOM64EXPlus"
export PORT_NAME="DOOM64EXPlus"
export ICONSFILENAME="DOOM64EXPlus"
export EXECUTABLE_NAME="DOOM64EXPlus"

# constants
source ../common/constants.sh
source ../common/signing_values.local

export BUILT_PRODUCTS_DIR="release"
export WRAPPER_NAME="DOOM64EXPlus.app"
export CONTENTS_FOLDER_PATH="DOOM64EXPlus.app/Contents"
export EXECUTABLE_FOLDER_PATH="DOOM64EXPlus.app/Contents/MacOS"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="DOOM64EXPlus.app/Contents/Resources"
export FRAMEWORKS_FOLDER_PATH="DOOM64EXPlus.app/Contents/Frameworks"
export BUNDLE_ID="com.macsourceports.DOOM64EXPlus"
export HIGH_RESOLUTION_CAPABLE="true"

# Pre-notarized zip file (not what is shipped)
PRE_NOTARIZED_ZIP="${PRODUCT_NAME}_prenotarized.zip"

# Post-notarized zip file (shipped)
POST_NOTARIZED_ZIP="${PRODUCT_NAME}_notarized_$(date +"%Y-%m-%d").zip"


# dylibbundler -od -b -x "./DOOM64EXPlus.app/Contents/MacOS/DOOM64EXPlus" -d "./DOOM64EXPlus.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/

rm "./DOOM64EXPlus.app/Contents/MacOS/libfluidsynth.3.2.1.dylib";

if [ -d "./DOOM64EXPlus.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/" ]; then
rm -rf "./DOOM64EXPlus.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/" || exit 1;
fi
mkdir -p "./DOOM64EXPlus.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/";
echo cp /usr/local/opt/fluid-synth/lib/libfluidsynth.3.dylib "./DOOM64EXPlus.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/"
cp /usr/local/opt/fluid-synth/lib/libfluidsynth.3.dylib "./DOOM64EXPlus.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/"

if [ -d "./DOOM64EXPlus.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/" ]; then
rm -rf "./DOOM64EXPlus.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/" || exit 1;
fi
mkdir -p "./DOOM64EXPlus.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/";
echo cp /opt/homebrew/opt/fluid-synth/lib/libfluidsynth.3.dylib "./DOOM64EXPlus.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/"
cp /opt/homebrew/opt/fluid-synth/lib/libfluidsynth.3.dylib "./DOOM64EXPlus.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/"

install_name_tool -change /opt/local/lib/libz.1.dylib @executable_path/libz.1.dylib DOOM64EXPlus.app/Contents/MacOS/DOOM64EXPlus
install_name_tool -change /opt/local/lib/libpng16.16.dylib @executable_path/libpng16.16.dylib DOOM64EXPlus.app/Contents/MacOS/DOOM64EXPlus
install_name_tool -change /opt/local/lib/libSDL2_net-2.0.0.dylib @executable_path/libSDL2_net-2.0.0.dylib DOOM64EXPlus.app/Contents/MacOS/DOOM64EXPlus
install_name_tool -change /opt/local/lib/libSDL2-2.0.0.dylib @executable_path/libSDL2-2.0.0.dylib DOOM64EXPlus.app/Contents/MacOS/DOOM64EXPlus
install_name_tool -change /usr/local/opt/fluid-synth/lib/libfluidsynth.3.dylib @executable_path/${X86_64_LIBS_FOLDER}/libfluidsynth.3.dylib DOOM64EXPlus.app/Contents/MacOS/DOOM64EXPlus
install_name_tool -change /opt/homebrew/opt/fluid-synth/lib/libfluidsynth.3.dylib @executable_path/${ARM64_LIBS_FOLDER}/libfluidsynth.3.dylib DOOM64EXPlus.app/Contents/MacOS/DOOM64EXPlus

dylibbundler -b -x "./DOOM64EXPlus.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/libfluidsynth.3.dylib" -d "./DOOM64EXPlus.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
dylibbundler -b -x "./DOOM64EXPlus.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/libfluidsynth.3.dylib" -d "./DOOM64EXPlus.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/

codesign --force --options runtime --deep --sign "${SIGNING_IDENTITY}" DOOM64EXPlus.app

if [ "$1" == "notarize" ]; then

	# notarize app

	# create the zip to send to the notarization service
	echo "zipping..."
	echo ditto -c -k --sequesterRsrc --keepParent "DOOM64EXPlus.app" "${PRE_NOTARIZED_ZIP}"
	ditto -c -k --sequesterRsrc --keepParent "DOOM64EXPlus.app" "${PRE_NOTARIZED_ZIP}"

	# submit app for notarization
	echo "submitting..."
	xcrun notarytool submit "$PRE_NOTARIZED_ZIP" --wait --key "../common/${AUTH_KEY_FILENAME}" --key-id "${AUTH_KEY_ID}" --issuer "${AUTH_KEY_ISSUER_ID}"

	# once notarization is complete, run stapler and exit
	echo "stapling..."
	xcrun stapler staple DOOM64EXPlus.app

	echo "notarized"
	echo "zipping notarized..."

	ditto -c -k --sequesterRsrc --keepParent DOOM64EXPlus.app "${POST_NOTARIZED_ZIP}"

	echo "done. ${POST_NOTARIZED_ZIP} contains notarized DOOM64EXPlus.app build."
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