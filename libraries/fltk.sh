source "./source_urls.sh"

export SOURCE_URL=${FLTK_URL}
export SOURCE_FOLDER="fltk-1.4.4"
export CMAKE_ARGS="-DFLTK_BUILD_HTML_DOCS=OFF -DFLTK_BUILD_PDF_DOCS=OFF -DFLTK_BUILD_TEST=OFF -DFLTK_BUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"

# sudo install_name_tool -id "@rpath/libgraphite2.3.dylib" /usr/local/lib/libgraphite2.3.dylib