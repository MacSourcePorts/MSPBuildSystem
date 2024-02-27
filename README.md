# MSPBuildSystem
Mac Source Ports Build System

This repo contains the Mac Source Ports build system files. As much as possible I'm trying to break away from using MSP-specific forks and instead use the original project's code, this makes it easier to incorporate their latest code and release strategies. 

In the scripts:

`PRODUCT_NAME` is the name given to the app bundle wraper (i.e., `PRODUCT_NAME.app`) and the dmg (i.e., `PRODUCT_NAME-1.0.dmg`)

`PROJECT_NAME` is the name of the actual project and the directory it's cloned into. 

`PORT_NAME` is the name of the source port, this one might have spaces, punctuation, etc., (i.e., `ArxLibertatis` versus `Arx Libertatis`)

If the notrarization fails get the submission GUID and run

`xcrun notarytool log (GUID) --key "../../MSPBuildSystem/common/${AUTH_KEY_FILENAME}" --key-id "${AUTH_KEY_ID}" --issuer "${AUTH_KEY_ISSUER_ID}"`

If you need to remove the quarantine from an app

`sudo xattr -r -d com.apple.quarantine /path/to/MyApp.app`