# move app bundle to a subfolder
mkdir -p ${BUILT_PRODUCTS_DIR}/source_folder
mv "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}" ${BUILT_PRODUCTS_DIR}/source_folder

# create dmg from that subfolder
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

# move app bundle back to parent folder
echo mv "${BUILT_PRODUCTS_DIR}/source_folder/${WRAPPER_NAME}" ${BUILT_PRODUCTS_DIR}
mv "${BUILT_PRODUCTS_DIR}/source_folder/${WRAPPER_NAME}" ${BUILT_PRODUCTS_DIR}
rm -rd ${BUILT_PRODUCTS_DIR}/source_folder

# a dated version (MSP_VERSION_DATE, see constants.sh) already has the date in it
if [ -n "${MSP_VERSION_DATE}" ]; then
  RELEASE_FOLDER="../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}"
else
  RELEASE_FOLDER="../MSPBuildSystem/${PROJECT_NAME}/release-${APP_VERSION}${ARCH_FOLDER}_${DATE_TIMESTAMP}"
fi

if [ "$1" != "skipdelete" ]; then
  if [ -d "${RELEASE_FOLDER}" ]; then
    rm -rf "${RELEASE_FOLDER}" || exit 1;
  fi
  mkdir -p "${RELEASE_FOLDER}";
fi

cp -a "${BUILT_PRODUCTS_DIR}/${WRAPPER_NAME}" "${RELEASE_FOLDER}"
cp -a "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}-${APP_VERSION}${ARCH_SUFFIX}.dmg" "${RELEASE_FOLDER}"

if [ "$1" != "skipcleanup" ] && [ "$2" != "skipcleanup" ]; then
    echo "Cleaning up"
    rm -rf ${X86_64_BUILD_FOLDER}
    rm -rf ${ARM64_BUILD_FOLDER}
    rm -rf ${BUILT_PRODUCTS_DIR}
else 
    echo "Skipping cleanup"
fi

echo "MSP_RELEASE_DMG=${RELEASE_FOLDER}/${PRODUCT_NAME}-${APP_VERSION}.dmg"
echo "MSP_RELEASE_VERSION=${APP_VERSION}"
