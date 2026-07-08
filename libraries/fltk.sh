source "./source_urls.sh"

export SOURCE_URL=${FLTK_URL}
export CMAKE_ARGS="-DFLTK_BUILD_HTML_DOCS=OFF -DFLTK_BUILD_PDF_DOCS=OFF -DFLTK_BUILD_TEST=OFF -DFLTK_BUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
export SOURCE_FOLDER=${SOURCE_FOLDER/-source/}
echo $SOURCE_FOLDER
source "../common/cmake_build.sh"

# sudo install_name_tool -id "@rpath/libgraphite2.3.dylib" /usr/local/lib/libgraphite2.3.dylib