#move app bundle to a subfolder
mkdir -p ${BUILT_PRODUCTS_DIR}/source_folder
mv ${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME} ${BUILT_PRODUCTS_DIR}/source_folder

#create DMG from that subfolder
create-dmg \
  --volname "${PORT_NAME}" \
  --volicon "../MSPBuildSystem/common/msp_dmg.icns" \
  --background "../MSPBuildSystem/common/msp_dmg_background.png" \
  --window-pos 200 120 \
  --window-size 750 400 \
  --icon-size 100 \
  --icon "${WRAPPER_NAME}" 175 190 \
  --hide-extension "${WRAPPER_NAME}" \
  --app-drop-link 575 185 \
  --no-internet-enable \
  "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.dmg" \
  "${BUILT_PRODUCTS_DIR}/source_folder"

#move app bundle back to parent folder
mv ${BUILT_PRODUCTS_DIR}/source_folder/${WRAPPER_NAME} ${BUILT_PRODUCTS_DIR}
rm -rd ${BUILT_PRODUCTS_DIR}/source_folder

if [ -d "../MSPBuildSystem/yquake2/release-${APP_VERSION}" ]; then
	rm -rf "../MSPBuildSystem/yquake2/release-${APP_VERSION}" || exit 1;
fi
mkdir -p "../MSPBuildSystem/yquake2/release-${APP_VERSION}";

mv ${BUILT_PRODUCTS_DIR}/* "../MSPBuildSystem/yquake2/release-${APP_VERSION}"

rm -rf ${X86_64_BUILD_FOLDER}
rm -rf ${ARM64_BUILD_FOLDER}
rm -rf ${BUILT_PRODUCTS_DIR}