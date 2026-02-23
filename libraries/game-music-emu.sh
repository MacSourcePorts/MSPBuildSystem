source "./source_urls.sh"

export SOURCE_URL=${GAMEMUSICEMU_URL}
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DINSTALL_MANPAGES=OFF -DENABLE_UBSAN=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"

sudo install_name_tool -id "@rpath/libgme.0.dylib" /usr/local/lib/libgme.0.dylib