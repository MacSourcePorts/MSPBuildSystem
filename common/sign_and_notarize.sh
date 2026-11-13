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

# If anything below fails, leave this marker so package_dmg.sh refuses to
# package an unsigned/unnotarized app. Most build scripts don't check this
# script's exit code, but they all end with package_dmg.sh.
NOTARIZE_FAILED_MARKER="$PWD/${BUILT_PRODUCTS_DIR}/.${WRAPPER_NAME}.notarize-failed"
rm -f "${NOTARIZE_FAILED_MARKER}"

fail() {
	echo "error: $1" >&2
	echo "$1" > "${NOTARIZE_FAILED_MARKER}"
	exit 1
}

# sign the resulting app bundle
echo "signing..."
if [ "$2" == "entitlements" ]; then
	echo codesign --force --options runtime --deep  --entitlements "${ENTITLEMENTS_FILE}" --sign "${SIGNING_IDENTITY}" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
	codesign --force --options runtime --deep  --entitlements "${ENTITLEMENTS_FILE}" --sign "${SIGNING_IDENTITY}" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}" || fail "codesign failed for ${WRAPPER_NAME}"
else
	echo codesign --force --options runtime --deep --sign "${SIGNING_IDENTITY}" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}"
	codesign --force --options runtime --deep --sign "${SIGNING_IDENTITY}" "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}" || fail "codesign failed for ${WRAPPER_NAME}"
fi

if [ "$1" == "notarize" ]; then

    cd ${BUILT_PRODUCTS_DIR} || fail "can't cd to ${BUILT_PRODUCTS_DIR}"

	# notarize app

	# create the zip to send to the notarization service
	echo "zipping..."
	ditto -c -k --sequesterRsrc --keepParent "${WRAPPER_NAME}" "${PRE_NOTARIZED_ZIP}" || fail "couldn't zip ${WRAPPER_NAME} for notarization"

	# submit app for notarization
	echo "submitting..."
	# notarytool can exit 0 without the app being accepted (e.g. status: Invalid),
	# so check the final status line too. Errors like an unaccepted Apple
	# developer agreement exit nonzero.
	NOTARY_LOG=$(mktemp)
	xcrun notarytool submit "$PRE_NOTARIZED_ZIP" --wait --key "../../MSPBuildSystem/common/${AUTH_KEY_FILENAME}" --key-id "${AUTH_KEY_ID}" --issuer "${AUTH_KEY_ISSUER_ID}" 2>&1 | tee "${NOTARY_LOG}"
	NOTARY_EXIT=${PIPESTATUS[0]}
	NOTARY_STATUS=$(grep -E '^[[:space:]]*status:' "${NOTARY_LOG}" | tail -1 | sed -E 's/^[[:space:]]*status:[[:space:]]*//')
	rm -f "${NOTARY_LOG}"
	if [ "${NOTARY_EXIT}" -ne 0 ]; then
		fail "notarytool submit failed (exit ${NOTARY_EXIT}) for ${WRAPPER_NAME}"
	fi
	if [ "${NOTARY_STATUS}" != "Accepted" ]; then
		fail "notarization of ${WRAPPER_NAME} was not accepted (status: ${NOTARY_STATUS:-unknown})"
	fi

	# once notarization is complete, run stapler and exit
	echo "stapling..."
	xcrun stapler staple "$WRAPPER_NAME" || fail "stapling ${WRAPPER_NAME} failed"

	echo "notarized"
	echo "zipping notarized..."

	ditto -c -k --sequesterRsrc --keepParent "${WRAPPER_NAME}" "${POST_NOTARIZED_ZIP}"

	echo "done. ${POST_NOTARIZED_ZIP} contains notarized "${WRAPPER_NAME}" build."
fi