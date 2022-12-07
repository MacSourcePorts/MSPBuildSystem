# game/app specific values
export APP_VERSION="1.01"
export PRODUCT_NAME="Extractor"
export PROJECT_NAME="Extractor"
export PORT_NAME="Extractor"
export ICONSFILENAME="Extractor"
export EXECUTABLE_NAME="Extractor"

# constants
source ../common/constants.sh
source ../common/signing_values.local

export BUILT_PRODUCTS_DIR="release"
export WRAPPER_NAME="Extractor.app"
export CONTENTS_FOLDER_PATH="Extractor.app/Contents"
export EXECUTABLE_FOLDER_PATH="Extractor.app/Contents/MacOS"
export UNLOCALIZED_RESOURCES_FOLDER_PATH="Extractor.app/Contents/Resources"
export FRAMEWORKS_FOLDER_PATH="Extractor.app/Contents/Frameworks"
export BUNDLE_ID="com.macsourceports.Extractor"
export HIGH_RESOLUTION_CAPABLE="true"

# Pre-notarized zip file (not what is shipped)
PRE_NOTARIZED_ZIP="${PRODUCT_NAME}_prenotarized.zip"

# Post-notarized zip file (shipped)
POST_NOTARIZED_ZIP="${PRODUCT_NAME}_notarized_$(date +"%Y-%m-%d").zip"


# dylibbundler -od -b -x "./Extractor.app/Contents/MacOS/Extractor" -d "./Extractor.app/Contents/MacOS/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/

install_name_tool -change /usr/local/opt/xz/lib/liblzma.5.dylib @executable_path/../Frameworks/liblzma.dylib Extractor.app/Contents/MacOS/Extractor
install_name_tool -change /opt/homebrew/opt/xz/lib/liblzma.5.dylib @executable_path/../Frameworks/liblzma.dylib Extractor.app/Contents/MacOS/Extractor

install_name_tool -change /usr/local/opt/xz/lib/liblzma.5.dylib @executable_path/../Frameworks/liblzma.dylib Extractor.app/Contents/Frameworks/libboost_iostreams.dylib

dylibbundler -od -b -x "./Extractor.app/Contents/Frameworks/libboost_iostreams.dylib" -d "./Extractor.app/Contents/MacOS/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/

codesign --force --options runtime --deep --sign "${SIGNING_IDENTITY}" Extractor.app

if [ "$1" == "notarize" ]; then

	# notarize app

	# create the zip to send to the notarization service
	echo "zipping..."
	echo ditto -c -k --sequesterRsrc --keepParent "Extractor.app" "${PRE_NOTARIZED_ZIP}"
	ditto -c -k --sequesterRsrc --keepParent "Extractor.app" "${PRE_NOTARIZED_ZIP}"

	# submit app for notarization
	echo "submitting..."
	xcrun notarytool submit "$PRE_NOTARIZED_ZIP" --wait --key "../../MSPBuildSystem/common/${AUTH_KEY_FILENAME}" --key-id "${AUTH_KEY_ID}" --issuer "${AUTH_KEY_ISSUER_ID}"

	# once notarization is complete, run stapler and exit
	echo "stapling..."
	xcrun stapler staple Extractor.app

	echo "notarized"
	echo "zipping notarized..."

	ditto -c -k --sequesterRsrc --keepParent Extractor.app "${POST_NOTARIZED_ZIP}"

	echo "done. ${POST_NOTARIZED_ZIP} contains notarized Extractor.app build."
fi