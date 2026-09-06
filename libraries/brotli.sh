source "./source_urls.sh"

export SOURCE_URL=${BROTLI_URL}
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"

sudo install_name_tool -id "@rpath/libbrotlicommon.1.dylib" /usr/local/lib/libbrotlicommon.1.dylib
sudo install_name_tool -id "@rpath/libbrotlidec.1.1.0.dylib" /usr/local/lib/libbrotlidec.1.1.0.dylib
sudo install_name_tool -change /usr/local/lib/libbrotlicommon.1.dylib @rpath/libbrotlicommon.1.dylib /usr/local/lib/libbrotlidec.1.1.0.dylib
sudo install_name_tool -id "@rpath/libbrotlienc.1.1.0.dylib" /usr/local/lib/libbrotlienc.1.1.0.dylib
sudo install_name_tool -change /usr/local/lib/libbrotlicommon.1.dylib @rpath/libbrotlicommon.1.dylib /usr/local/lib/libbrotlienc.1.1.0.dylib