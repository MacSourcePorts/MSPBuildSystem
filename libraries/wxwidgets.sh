# NOTE: Has an issue when linking libwxscintilla-3.2.a / libwx_osx_cocoau_stc-3.2.0.2.3.dylib
# Unsure if this is going to be an issue but moving on for now.

export SOURCE_URL="https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.5/wxWidgets-3.2.5.tar.bz2"
export SOURCE_FILE="wxWidgets-3.2.5.tar.bz2"
export CONFIGURE_ARGS="--enable-clipboard --enable-controls --enable-dataviewctrl --enable-display --enable-dnd --enable-graphics_ctx --enable-std_string --enable-svg --enable-unicode --enable-webviewwebkit --with-expat --with-libjpeg --with-libpng --with-libtiff --with-opengl --with-zlib --disable-dependency-tracking --disable-tests --disable-precomp-headers --disable-monolithic --with-osx_cocoa --with-libiconv"
export MAKE_ARGS="-j`sysctl -n hw.ncpu`"

source "../common/get_source.sh"
source "../common/make_build.sh"