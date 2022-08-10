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
  "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}-${APP_VERSION}${ARCH_SUFFIX}.dmg" \
  "${BUILT_PRODUCTS_DIR}/source_folder"

#move app bundle back to parent folder
mv ${BUILT_PRODUCTS_DIR}/source_folder/${WRAPPER_NAME} ${BUILT_PRODUCTS_DIR}
rm -rd ${BUILT_PRODUCTS_DIR}/source_folder

if [ "$1" != "skipdelete" ]; then
  if [ -d "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}" ]; then
    rm -rf "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}" || exit 1;
  fi
  mkdir -p "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}";
fi

mv ${BUILT_PRODUCTS_DIR}/* "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}"

if [ "$1" != "skipcleanup" ]; then
  rm -rf ${X86_64_BUILD_FOLDER}
  rm -rf ${ARM64_BUILD_FOLDER}
  rm -rf ${BUILT_PRODUCTS_DIR}
fi