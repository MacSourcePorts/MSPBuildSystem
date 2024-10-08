## TODO!!
## TODO!!
## TODO!!

## Make things go to the right directories!
## Until then make a copy of what Xcode releases, put it in the folder with this script, zip it up, then run it. Then delete that app and zip.

## TODO!!
## TODO!!
## TODO!!

# game/app specific values
export APP_VERSION="1.2.0"
export PRODUCT_NAME="Gardens of Kadesh"
export PROJECT_NAME="gardens-of-kadesh"
export PORT_NAME="gardens-of-kadesh"
export ICONSFILENAME="gardens-of-kadesh"
export EXECUTABLE_NAME="Homeworld"

# constants
source ../common/constants.sh
source ../common/signing_values.local

export BUILT_PRODUCTS_DIR="release"
export WRAPPER_NAME="Gardens of Kadesh.app"
export CONTENTS_FOLDER_PATH="Gardens of Kadesh.app/Contents"
export EXECUTABLE_FOLDER_PATH="Gardens of Kadesh.app/Contents/MacOS"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="Gardens of Kadesh.app/Contents/Resources"
export FRAMEWORKS_FOLDER_PATH="Gardens of Kadesh.app/Contents/Frameworks"
export BUNDLE_ID="com.macsourceports.gardens-of-kadesh"
export HIGH_RESOLUTION_CAPABLE="true"

# Pre-notarized zip file (not what is shipped)
PRE_NOTARIZED_ZIP="${PRODUCT_NAME}_prenotarized.zip"

# Post-notarized zip file (shipped)
POST_NOTARIZED_ZIP="${PRODUCT_NAME}_notarized_$(date +"%Y-%m-%d").zip"

codesign --force --options runtime --deep --sign "${SIGNING_IDENTITY}" "Gardens of Kadesh.app"

if [ "$1" == "notarize" ]; then

	# notarize app

	# create the zip to send to the notarization service
	echo "zipping..."
	echo ditto -c -k --sequesterRsrc --keepParent "Gardens of Kadesh.app" "${PRE_NOTARIZED_ZIP}"
	ditto -c -k --sequesterRsrc --keepParent "Gardens of Kadesh.app" "${PRE_NOTARIZED_ZIP}"

	# submit app for notarization
	echo "submitting..."
	xcrun notarytool submit "$PRE_NOTARIZED_ZIP" --wait --key "../common/${AUTH_KEY_FILENAME}" --key-id "${AUTH_KEY_ID}" --issuer "${AUTH_KEY_ISSUER_ID}"

	# once notarization is complete, run stapler and exit
	echo "stapling..."
	xcrun stapler staple "Gardens of Kadesh.app"

	echo "notarized"
	echo "zipping notarized..."

	ditto -c -k --sequesterRsrc --keepParent "Gardens of Kadesh.app" "${POST_NOTARIZED_ZIP}"

	echo "done. ${POST_NOTARIZED_ZIP} contains notarized `Gardens of Kadesh.app` build."
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