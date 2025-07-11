export SOURCE_URL="https://github.com/fltk/fltk/releases/download/release-1.4.3/fltk-1.4.3-source.tar.bz2"
export SOURCE_FOLDER="fltk-1.4.3"
export CMAKE_ARGS="-DFLTK_BUILD_HTML_DOCS=OFF -DFLTK_BUILD_PDF_DOCS=OFF -DFLTK_BUILD_TEST=OFF -DFLTK_BUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"

# sudo install_name_tool -id "@rpath/libgraphite2.3.dylib" /usr/local/lib/libgraphite2.3.dylib