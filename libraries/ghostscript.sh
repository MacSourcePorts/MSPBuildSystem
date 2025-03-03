export SOURCE_URL="https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs10031/ghostpdl-10.03.1.tar.xz"
export CONFIGURE_ARGS="--disable-compile-inits --disable-cups --disable-gtk --with-system-libtiff --without-x --enable-shared"

source "../common/get_source.sh"

patch -d source/${SOURCE_FOLDER} < ghostscript.diff

sudo install_name_tool -id "/usr/local/lib/libfontconfig.1.dylib" /usr/local/lib/libfontconfig.1.dylib
sudo install_name_tool -change @rpath/libpng16.16.dylib /usr/local/lib/libpng16.16.dylib /usr/local/lib/libfreetype.6.dylib

source "../common/make_build_lipo.sh"
sudo make install-so

# NOTE: The libraries are installed with names like "libgs.dylib.10.03" instead of "libgs.10.03.dylib"
# If this proves to be an issue we may need to figure out the proper way to rename them

sudo install_name_tool -id "@rpath/libfontconfig.1.dylib" /usr/local/lib/libfontconfig.1.dylib
sudo install_name_tool -change /usr/local/lib/libpng16.16.dylib @rpath/libpng16.16.dylib /usr/local/lib/libfreetype.6.dylib