source "./source_urls.sh"

export SOURCE_URL=${WXWIDGETS_URL}
export CONFIGURE_ARGS="--enable-clipboard --enable-controls --enable-dataviewctrl --enable-display --enable-dnd --enable-graphics_ctx --enable-svg --enable-webviewwebkit --with-expat --with-libjpeg --with-libpng --with-libtiff --with-libwebp --with-opengl --with-zlib --disable-tests --disable-precomp-headers --disable-monolithic --with-osx_cocoa --with-libiconv"
export MAKE_ARGS="-j`sysctl -n hw.ncpu`"

source "../common/get_source.sh"

WX_VERSION=${SOURCE_FOLDER#wxWidgets-}

gsed -i "s|-framework AGL||" source/${SOURCE_FOLDER}/configure.ac

# The AVKit check compiles with -x objective-c++, which clang rejects when newer
# autoconf adds -std=gnu23 to CC. The check then fails, AVKit isn't linked, and
# libwx_osx_cocoau_media fails with undefined AVPlayerView. Always link it.
gsed -i 's|GST_LIBS="-framework AVFoundation -framework CoreMedia"|GST_LIBS="-framework AVFoundation -framework CoreMedia -weak_framework AVKit"|' source/${SOURCE_FOLDER}/configure.ac source/${SOURCE_FOLDER}/configure

source "../common/make_build.sh"


sudo install_name_tool -id "@rpath/libwx_baseu-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_baseu_net-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_baseu_net-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_baseu_xml-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_baseu_xml-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_adv-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_adv-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_aui-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_aui-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_gl-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_gl-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_html-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_html-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_media-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_media-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_propgrid-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_propgrid-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_qa-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_qa-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_ribbon-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_ribbon-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_richtext-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_richtext-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_stc-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_stc-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_webview-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_webview-${WX_VERSION}.0.0.dylib
sudo install_name_tool -id "@rpath/libwx_osx_cocoau_xrc-${WX_VERSION}.0.0.dylib" /usr/local/lib/libwx_osx_cocoau_xrc-${WX_VERSION}.0.0.dylib

sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_baseu_net-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_baseu_xml-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_adv-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_aui-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_gl-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_html-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_media-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_propgrid-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_qa-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_ribbon-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_richtext-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_stc-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_webview-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_xrc-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib @rpath/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_adv-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib @rpath/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_aui-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib @rpath/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_gl-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib @rpath/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_html-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib @rpath/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_media-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib @rpath/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_propgrid-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib @rpath/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_qa-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib @rpath/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_ribbon-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib @rpath/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_richtext-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib @rpath/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_stc-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib @rpath/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_webview-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib @rpath/libwx_osx_cocoau_core-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_xrc-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_html-${WX_VERSION}.0.0.dylib @rpath/libwx_osx_cocoau_html-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_richtext-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_osx_cocoau_html-${WX_VERSION}.0.0.dylib @rpath/libwx_osx_cocoau_html-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_xrc-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu_xml-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu_xml-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_qa-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu_xml-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu_xml-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_richtext-${WX_VERSION}.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libwx_baseu_xml-${WX_VERSION}.0.0.dylib @rpath/libwx_baseu_xml-${WX_VERSION}.0.0.dylib /usr/local/lib/libwx_osx_cocoau_xrc-${WX_VERSION}.0.0.dylib

sudo install_name_tool -add_rpath /usr/local/lib /usr/local/bin/wxrc-${WX_VERSION%.*}