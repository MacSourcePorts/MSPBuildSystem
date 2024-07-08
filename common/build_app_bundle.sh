if [ "$1" != "skiplipo" ]; then
    # bundle arch-specific libraries
    cd ${X86_64_BUILD_FOLDER}
    dylibbundler -of -cd -b -x "./${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/

    cd ..
    cd ${ARM64_BUILD_FOLDER}
    dylibbundler -of -cd -b -x "./${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/

    cd ..
fi

# make the app bundle directories
if [ ! -d "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}" || exit 1;
fi
if [ ! -d "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" ]; then
	mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" || exit 1;
fi

echo -n ${PKGINFO} > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/PkgInfo" || exit 1;

# create Info.Plist
PLIST="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>CFBundleExecutable</key>
    <string>${EXECUTABLE_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>${ICONSFILENAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${PRODUCT_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${APP_VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${APP_VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.7</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <${HIGH_RESOLUTION_CAPABLE}/>
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.games</string>
</dict>
</plist>
"
echo "${PLIST}" > "${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Info.plist"

if [ "$1" != "skiplipo" ]; then
    #lipo the executable
    lipo "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}" -create

    #copy resources
    mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}"
    cp -a "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}"

    mkdir "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}"
    cp -a "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}"

    cp -a "${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/." "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi

# doing the icons last to overwrite theirs
# deleting their icon first to eliminate case insensivity issues
rm "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}";
cp "${ICONSDIR}/${ICONS}" "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}" || exit 1;

echo "bundle done."