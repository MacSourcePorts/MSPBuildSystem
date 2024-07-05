export SOURCE_URL="https://downloads.sourceforge.net/project/libpng/libpng16/1.6.43/libpng-1.6.43.tar.xz"
export MAKE_ARGS="--disable-dependency-tracking --disable-silent-rules"

"../common/make_build.sh"

# sudo install_name_tool -id "@rpath/libSDL2_net-2.0.0.dylib" /usr/local/lib/libSDL2_net-2.0.0.dylib