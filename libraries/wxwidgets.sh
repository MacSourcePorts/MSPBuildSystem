export SOURCE_URL="https://github.com/wxWidgets/wxWidgets/releases/download/v3.3.1/wxWidgets-3.3.1.tar.bz2"
export SOURCE_FILE="wxWidgets-3.3.1.tar.bz2"
export CONFIGURE_ARGS="--enable-clipboard --enable-controls --enable-dataviewctrl --enable-display --enable-dnd --enable-graphics_ctx --enable-svg --enable-webviewwebkit --with-expat --with-libjpeg --with-libpng --with-libtiff --with-libwebp --with-opengl --with-zlib --disable-tests --disable-precomp-headers --disable-monolithic --with-osx_cocoa --with-libiconv"
export MAKE_ARGS="-j`sysctl -n hw.ncpu`"

source "../common/get_source.sh"

gsed -i "s|-framework AGL||" source/wxWidgets-3.3.1/configure.ac

source "../common/make_build.sh"


sudo install_name_tool -id "@rpath/libwx_baseu-3.3.1.0.0.dylib" /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_baseu_net-3.3.1.0.0.dylib" /usr/local/lib/libwx_baseu_net-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_baseu_xml-3.3.1.0.0.dylib" /usr/local/lib/libwx_baseu_xml-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_adv-3.3.1.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_adv-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_aui-3.3.1.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_aui-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_core-3.3.1.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_core-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_gl-3.3.1.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_gl-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_html-3.3.1.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_html-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_media-3.3.1.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_media-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_propgrid-3.3.1.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_propgrid-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_qa-3.3.1.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_qa-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_ribbon-3.3.1.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_ribbon-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_richtext-3.3.1.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_richtext-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_stc-3.3.1.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_stc-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_webview-3.3.1.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_webview-3.3.1.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_xrc-3.3.1.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_xrc-3.3.1.0.0.dylib

sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_baseu_net-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_baseu_xml-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_adv-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_aui-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_core-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_gl-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_html-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_media-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_propgrid-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_qa-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_ribbon-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_richtext-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_stc-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_webview-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-3.3.1.0.0.dylib @rpath/libwx_baseu-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_xrc-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-3.3.1.0.0.dylib @rpath/libwx_osx_cocoau_core-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_adv-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-3.3.1.0.0.dylib @rpath/libwx_osx_cocoau_core-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_aui-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-3.3.1.0.0.dylib @rpath/libwx_osx_cocoau_core-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_gl-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-3.3.1.0.0.dylib @rpath/libwx_osx_cocoau_core-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_html-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-3.3.1.0.0.dylib @rpath/libwx_osx_cocoau_core-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_media-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-3.3.1.0.0.dylib @rpath/libwx_osx_cocoau_core-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_propgrid-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-3.3.1.0.0.dylib @rpath/libwx_osx_cocoau_core-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_qa-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-3.3.1.0.0.dylib @rpath/libwx_osx_cocoau_core-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_ribbon-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-3.3.1.0.0.dylib @rpath/libwx_osx_cocoau_core-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_richtext-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-3.3.1.0.0.dylib @rpath/libwx_osx_cocoau_core-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_stc-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-3.3.1.0.0.dylib @rpath/libwx_osx_cocoau_core-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_webview-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-3.3.1.0.0.dylib @rpath/libwx_osx_cocoau_core-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_xrc-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_html-3.3.1.0.0.dylib @rpath/libwx_osx_cocoau_html-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_richtext-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_html-3.3.1.0.0.dylib @rpath/libwx_osx_cocoau_html-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_xrc-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu_xml-3.3.1.0.0.dylib @rpath/libwx_baseu_xml-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_qa-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu_xml-3.3.1.0.0.dylib @rpath/libwx_baseu_xml-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_richtext-3.3.1.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu_xml-3.3.1.0.0.dylib @rpath/libwx_baseu_xml-3.3.1.0.0.dylib /usr/local/lib/libwx_osx_cocoau_xrc-3.3.1.0.0.dylib
