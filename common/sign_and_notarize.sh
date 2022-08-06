# user-specific values
# specify the actual values in a separate file called signing_values.local

# ****************************************************************************************
# identity as specified in Keychain
SIGNING_IDENTITY="Developer ID Application: Your Name (XXXXXXXXX)"

# App Store Connect API info
# https://appstoreconnect.apple.com/access/api

# filename to the auth key from App Store Connect API
AUTH_KEY_FILENAME="AuthKey_XXXXXXXXXX.p8"

# auth key from App Store Connect API
AUTH_KEY_ID="XXXXXXXXXX"

# auth key issuer ID from App Store Connect API
AUTH_KEY_ISSUER_ID="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
# ****************************************************************************************

source ../MSPBuildSystem/common/signing_values.local

# Pre-notarized zip file (not what is shipped)
PRE_NOTARIZED_ZIP="${PRODUCT_NAME}_prenotarized.zip"

# Post-notarized zip file (shipped)
POST_NOTARIZED_ZIP="${PRODUCT_NAME}_notarized_$(date +"%Y-%m-%d").zip"

# sign the resulting app bundle
echo "signing..."
if [ "$2" == "entitlements" ]; then
	echo codesign --force --options runtime --deep  --entitlements "${ENTITLEMENTS_FILE}" --sign "${SIGNING_IDENTITY}" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
	codesign --force --options runtime --deep  --entitlements "${ENTITLEMENTS_FILE}" --sign "${SIGNING_IDENTITY}" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
else
	echo codesign --force --options runtime --deep --sign "${SIGNING_IDENTITY}" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
	codesign --force --options runtime --deep --sign "${SIGNING_IDENTITY}" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
fi

if [ "$1" == "notarize" ]; then

    cd ${BUILT_PRODUCTS_DIR}

	# notarize app

	# create the zip to send to the notarization service
	echo "zipping..."
	ditto -c -k --sequesterRsrc --keepParent "${WRAPPER_NAME}" "${PRE_NOTARIZED_ZIP}"

	# submit app for notarization
	echo "submitting..."
	xcrun notarytool submit "$PRE_NOTARIZED_ZIP" --wait --key "../../MSPBuildSystem/common/${AUTH_KEY_FILENAME}" --key-id "${AUTH_KEY_ID}" --issuer "${AUTH_KEY_ISSUER_ID}"

	# once notarization is complete, run stapler and exit
	echo "stapling..."
	xcrun stapler staple "$WRAPPER_NAME"

	echo "notarized"
	echo "zipping notarized..."

	ditto -c -k --sequesterRsrc --keepParent "${WRAPPER_NAME}" "${POST_NOTARIZED_ZIP}"

	echo "done. ${POST_NOTARIZED_ZIP} contains notarized "${WRAPPER_NAME}" build."
fi