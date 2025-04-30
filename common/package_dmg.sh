#move app bundle to a subfolder
mkdir -p ${BUILT_PRODUCTS_DIR}/source_folder
mv "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}" ${BUILT_PRODUCTS_DIR}/source_folder

#create DMG from that subfolder
create-dmg \
  --volname "${PORT_NAME}" \
  --volicon "../MSPBuildSystem/common/msp_dmg.icns" \
  --background "../MSPBuildSystem/common/msp_dmg_background.tiff" \
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
echo mv "${BUILT_PRODUCTS_DIR}/source_folder/${WRAPPER_NAME}" ${BUILT_PRODUCTS_DIR}
mv "${BUILT_PRODUCTS_DIR}/source_folder/${WRAPPER_NAME}" ${BUILT_PRODUCTS_DIR}
rm -rd ${BUILT_PRODUCTS_DIR}/source_folder

if [ "$1" != "skipdelete" ]; then
  if [ -d "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}_${DATE_TIMESTAMP}" ]; then
    rm -rf "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}_${DATE_TIMESTAMP}" || exit 1;
  fi
  mkdir -p "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}_${DATE_TIMESTAMP}";
fi

cp -a "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}" "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}_${DATE_TIMESTAMP}"
cp -a "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}-${APP_VERSION}${ARCH_SUFFIX}.dmg" "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}_${DATE_TIMESTAMP}"
if [ -f "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}_prenotarized.zip" ] ; then
  cp -a "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}_prenotarized.zip" "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}_${DATE_TIMESTAMP}"
  cp -a "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}_notarized_$(date +"%Y-%m-%d").zip" "../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}_${DATE_TIMESTAMP}"
fi

if [ "$1" != "skipcleanup" ] && [ "$2" != "skipcleanup" ]; then
    echo "Cleaning up"
    rm -rf ${X86_64_BUILD_FOLDER}
    rm -rf ${ARM64_BUILD_FOLDER}
    rm -rf ${BUILT_PRODUCTS_DIR}
else 
    echo "Skipping cleanup"
fi