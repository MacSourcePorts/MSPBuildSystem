source "./source_urls.sh"

export PATH="/usr/local/bin:$PATH"
export SOURCE_URL=${BISON_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --enable-relocatable M4=m4"

source "../common/get_source.sh"

sudo install_name_tool -id "/usr/local/lib/libtextstyle.0.dylib" /usr/local/lib/libtextstyle.0.dylib
sudo install_name_tool -id "/usr/local/lib/libintl.8.dylib" /usr/local/lib/libintl.8.dylib

source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libintl.8.dylib" /usr/local/lib/libintl.8.dylib
sudo install_name_tool -id "@rpath/libtextstyle.0.dylib" /usr/local/lib/libtextstyle.0.dylib
