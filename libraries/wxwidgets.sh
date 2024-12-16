# NOTE: Has an issue when linking libwxscintilla-3.2.a / libwx_osx_cocoau_stc-3.2.0.2.3.dylib
# Unsure if this is going to be an issue but moving on for now.

export SOURCE_URL="https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.5/wxWidgets-3.2.5.tar.bz2"
export SOURCE_FILE="wxWidgets-3.2.5.tar.bz2"
export CONFIGURE_ARGS="--enable-clipboard --enable-controls --enable-dataviewctrl --enable-display --enable-dnd --enable-graphics_ctx --enable-std_string --enable-svg --enable-unicode --enable-webviewwebkit --with-expat --with-libjpeg --with-libpng --with-libtiff --with-opengl --with-zlib --disable-dependency-tracking --disable-tests --disable-precomp-headers --disable-monolithic --with-osx_cocoa --with-libiconv"
export MAKE_ARGS="-j`sysctl -n hw.ncpu`"

source "../common/get_source.sh"
source "../common/make_build.sh"


sudo install_name_tool -id "@rpath/libwx_baseu-3.2.0.2.3.dylib" /usr/local/lib/libwx_baseu-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_baseu_net-3.2.0.2.3.dylib" /usr/local/lib/libwx_baseu_net-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_baseu_xml-3.2.0.2.3.dylib" /usr/local/lib/libwx_baseu_xml-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_adv-3.2.0.2.3.dylib" /usr/local/lib/libwx_osx_cocoau_adv-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_aui-3.2.0.2.3.dylib" /usr/local/lib/libwx_osx_cocoau_aui-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_core-3.2.0.2.3.dylib" /usr/local/lib/libwx_osx_cocoau_core-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_gl-3.2.0.2.3.dylib" /usr/local/lib/libwx_osx_cocoau_gl-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_html-3.2.0.2.3.dylib" /usr/local/lib/libwx_osx_cocoau_html-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_media-3.2.0.2.3.dylib" /usr/local/lib/libwx_osx_cocoau_media-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_propgrid-3.2.0.2.3.dylib" /usr/local/lib/libwx_osx_cocoau_propgrid-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_qa-3.2.0.2.3.dylib" /usr/local/lib/libwx_osx_cocoau_qa-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_ribbon-3.2.0.2.3.dylib" /usr/local/lib/libwx_osx_cocoau_ribbon-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_richtext-3.2.0.2.3.dylib" /usr/local/lib/libwx_osx_cocoau_richtext-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_stc-3.2.0.2.3.dylib" /usr/local/lib/libwx_osx_cocoau_stc-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_webview-3.2.0.2.3.dylib" /usr/local/lib/libwx_osx_cocoau_webview-3.2.0.2.3.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_xrc-3.2.0.2.3.dylib" /usr/local/lib/libwx_osx_cocoau_xrc-3.2.0.2.3.dylib

sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_osx_cocoau_core-3.2.0.2.3.dylib @rpath/libwx_osx_cocoau_core-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_webview-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu-3.2.0.2.3.dylib @rpath/libwx_baseu-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_webview-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_osx_cocoau_core-3.2.0.2.3.dylib @rpath/libwx_osx_cocoau_core-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_aui-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu-3.2.0.2.3.dylib @rpath/libwx_baseu-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_aui-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu-3.2.0.2.3.dylib @rpath/libwx_baseu-3.2.0.2.3.dylib /usr/local/lib/libwx_baseu_net-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_osx_cocoau_core-3.2.0.2.3.dylib @rpath/libwx_osx_cocoau_core-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_xrc-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_osx_cocoau_html-3.2.0.2.3.dylib @rpath/libwx_osx_cocoau_html-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_xrc-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu-3.2.0.2.3.dylib @rpath/libwx_baseu-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_xrc-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu_xml-3.2.0.2.3.dylib @rpath/libwx_baseu_xml-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_xrc-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_osx_cocoau_core-3.2.0.2.3.dylib @rpath/libwx_osx_cocoau_core-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_qa-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu-3.2.0.2.3.dylib @rpath/libwx_baseu-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_qa-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu_xml-3.2.0.2.3.dylib @rpath/libwx_baseu_xml-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_qa-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_osx_cocoau_core-3.2.0.2.3.dylib @rpath/libwx_osx_cocoau_core-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_adv-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu-3.2.0.2.3.dylib @rpath/libwx_baseu-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_adv-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_osx_cocoau_core-3.2.0.2.3.dylib @rpath/libwx_osx_cocoau_core-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_html-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu-3.2.0.2.3.dylib @rpath/libwx_baseu-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_html-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_osx_cocoau_core-3.2.0.2.3.dylib @rpath/libwx_osx_cocoau_core-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_ribbon-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu-3.2.0.2.3.dylib @rpath/libwx_baseu-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_ribbon-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu-3.2.0.2.3.dylib @rpath/libwx_baseu-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_core-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_osx_cocoau_core-3.2.0.2.3.dylib @rpath/libwx_osx_cocoau_core-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_media-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu-3.2.0.2.3.dylib @rpath/libwx_baseu-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_media-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_osx_cocoau_core-3.2.0.2.3.dylib @rpath/libwx_osx_cocoau_core-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_propgrid-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu-3.2.0.2.3.dylib @rpath/libwx_baseu-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_propgrid-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_osx_cocoau_core-3.2.0.2.3.dylib @rpath/libwx_osx_cocoau_core-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_richtext-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_osx_cocoau_html-3.2.0.2.3.dylib @rpath/libwx_osx_cocoau_html-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_richtext-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu-3.2.0.2.3.dylib @rpath/libwx_baseu-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_richtext-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu_xml-3.2.0.2.3.dylib @rpath/libwx_baseu_xml-3.2.0.2.3.dylib /usr/local/lib/libwx_osx_cocoau_richtext-3.2.0.2.3.dylib
sudo install_name_tool -change /Users/tomkidd/Documents/GitHub/MacSourcePorts/MSPBuildSystem/libraries/source/wxWidgets-3.2.5/lib/libwx_baseu-3.2.0.2.3.dylib @rpath/libwx_baseu-3.2.0.2.3.dylib /usr/local/lib/libwx_baseu_xml-3.2.0.2.3.dylib

