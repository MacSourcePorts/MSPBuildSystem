# game/app specific values
export APP_VERSION="3.1.4"
export PRODUCT_NAME="freeciv"
export PROJECT_NAME="freeciv"
export PORT_NAME="freeciv"
export ICONSFILENAME="freeciv"
export EXECUTABLE_NAME="bin/freeciv-gtk3.22"
export PKGINFO="APPFCIV"
export GIT_TAG="R3_1_4"
export GIT_DEFAULT_BRANCH="main"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

# check out the latest release tag
echo git checkout tags/${GIT_TAG}
git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}

# DEBUG
if false; then

rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
mkdir -p "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}"
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
mkdir -p "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}"


cd ${ARM64_BUILD_FOLDER}

export PATH="/opt/homebrew/bin:$PATH"
export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig:$PKG_CONFIG_PATH"
export LDFLAGS="-L/opt/homebrew/lib -Wl,-rpath,/opt/homebrew/lib"
export CPPFLAGS="-I/opt/homebrew/include"

export PKG_CONFIG_PATH="/opt/homebrew/opt/icu4c/lib/pkgconfig:/opt/homebrew/opt/xz/lib/pkgconfig:/opt/homebrew/opt/zlib/lib/pkgconfig:$PKG_CONFIG_PATH"

../autogen.sh --disable-gtktest \
      --disable-sdl2framework \
      --disable-sdl2test \
      --disable-sdltest \
      --disable-silent-rules \
      --enable-client=gtk3.22 \
      --enable-fcdb=sqlite3 \
      --enable-ack-legacy \
      --enable-debug \
      --prefix=$(PWD)/ReleaseBuild

make CXX="/opt/homebrew/bin/g++-14" CC="/opt/homebrew/bin/gcc-14" -j$(sysctl -n hw.ncpu)
make install

cp -a "ReleaseBuild/." "${EXECUTABLE_FOLDER_PATH}"

cd ..

export PATH="/usr/local/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
export LDFLAGS="-L/usr/local/lib -Wl,-rpath,/usr/local/lib"
export CPPFLAGS="-I/usr/local/include"

export PKG_CONFIG_PATH="/usr/local/opt/icu4c/lib/pkgconfig:/usr/local/opt/xz/lib/pkgconfig:/usr/local/opt/zlib/lib/pkgconfig:$PKG_CONFIG_PATH"

cd ${X86_64_BUILD_FOLDER}

../autogen.sh --disable-gtktest \
      --disable-sdl2framework \
      --disable-sdl2test \
      --disable-sdltest \
      --disable-silent-rules \
      --enable-client=gtk3.22 \
      --enable-fcdb=sqlite3 \
      --enable-ack-legacy \
      --enable-debug \
      --prefix=$(PWD)/ReleaseBuild

make CXX="/usr/local/bin/g++-14" CC="/usr/local/bin/gcc-14" -j$(sysctl -n hw.ncpu)
make install

cp -a "ReleaseBuild/." "${EXECUTABLE_FOLDER_PATH}"

cd ..

# DEBUG
fi

# dylib and lipo the other executables
cd ${X86_64_BUILD_FOLDER}
dylibbundler -of -cd -b -x "./${EXECUTABLE_FOLDER_PATH}/bin/freeciv-manual" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
dylibbundler -of -cd -b -x "./${EXECUTABLE_FOLDER_PATH}/bin/freeciv-mp-gtk3" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
dylibbundler -of -cd -b -x "./${EXECUTABLE_FOLDER_PATH}/bin/freeciv-ruleup" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/
dylibbundler -of -cd -b -x "./${EXECUTABLE_FOLDER_PATH}/bin/freeciv-server" -d "./${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}/" -p @executable_path/${X86_64_LIBS_FOLDER}/

cd ..
cd ${ARM64_BUILD_FOLDER}
dylibbundler -of -cd -b -x "./${EXECUTABLE_FOLDER_PATH}/bin/freeciv-manual" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
dylibbundler -of -cd -b -x "./${EXECUTABLE_FOLDER_PATH}/bin/freeciv-mp-gtk3" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
dylibbundler -of -cd -b -x "./${EXECUTABLE_FOLDER_PATH}/bin/freeciv-ruleup" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/
dylibbundler -of -cd -b -x "./${EXECUTABLE_FOLDER_PATH}/bin/freeciv-server" -d "./${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}/" -p @executable_path/${ARM64_LIBS_FOLDER}/

cd ..

# hack to make sure the bin folder is there
mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/bin"

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

lipo "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/bin/freeciv-manual" "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/bin/freeciv-manual" -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/bin/freeciv-manual" -create
lipo "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/bin/freeciv-mp-gtk3" "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/bin/freeciv-mp-gtk3" -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/bin/freeciv-mp-gtk3" -create
lipo "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/bin/freeciv-ruleup" "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/bin/freeciv-ruleup" -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/bin/freeciv-ruleup" -create
lipo "${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/bin/freeciv-server" "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/bin/freeciv-server" -output "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/bin/freeciv-server" -create

echo "***" mv "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/bin"
mv "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${ARM64_LIBS_FOLDER}" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/bin"
mv "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/${X86_64_LIBS_FOLDER}" "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/bin"

mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/etc"
cp -a "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/etc/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/etc"

mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/lib"
cp -a "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/lib/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/lib"

mkdir -p "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/share"
cp -a "${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/share/." "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/share"

mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/share/icons"
cp -R /opt/homebrew/share/icons/Adwaita "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/share/icons"

mkdir -p "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/lib/gdk-pixbuf-2.0/2.10.0/loaders"
cp -R /opt/homebrew/lib/gdk-pixbuf-2.0/2.10.0/loaders/*.so "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/lib/gdk-pixbuf-2.0/2.10.0/loaders"

GDK_PIXBUF_MODULE_FILE="${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
/opt/homebrew/bin/gdk-pixbuf-query-loaders > "$GDK_PIXBUF_MODULE_FILE"
sed -i '' "s|/opt/homebrew/lib/|@executable_path/../Resources/lib/|g" "$GDK_PIXBUF_MODULE_FILE"

cp -R /opt/homebrew/share/mime "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/share"
/opt/homebrew/bin/update-mime-database "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/share/mime"

LAUNCHER="#!/bin/bash
export XDG_DATA_DIRS=\"@executable_path/../Resources/share:/usr/local/share:/usr/share\"
export GTK_DATA_PREFIX=\"@executable_path/../Resources\"
export GDK_PIXBUF_MODULE_FILE=\"@executable_path/../Resources/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache\"
export GIO_EXTRA_MODULES=\"@executable_path/../Resources/lib/gio/modules\"

exec \"@executable_path/freeciv-gtk3\" \"$@\"
"
echo "${LAUNCHER}" > "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/bin/freeciv-launcher"
chmod +x "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/bin/freeciv-launcher"

# redo Info.Plist
PLIST="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>CFBundleExecutable</key>
    <string>bin/freeciv-launcher</string>
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

#sign and notarize
# "../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
# "../MSPBuildSystem/common/package_dmg.sh" "skipcleanup"