export SOURCE_URL="https://github.com/akheron/jansson/releases/download/v2.14.1/jansson-2.14.1.tar.gz"
source "../common/get_source.sh"
source "../common/make_build.sh"


sudo install_name_tool -id "@rpath/libjansson.4.dylib" /usr/local/lib/libjansson.4.dylib