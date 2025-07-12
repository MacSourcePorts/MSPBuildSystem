export SOURCE_URL="https://github.com/libgme/game-music-emu/archive/refs/tags/0.6.3.zip"
export SOURCE_FILE="game-music-emu-0.6.3.zip"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DINSTALL_MANPAGES=OFF -DENABLE_UBSAN=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"

sudo install_name_tool -id "@rpath/libgme.0.dylib" /usr/local/lib/libgme.0.dylib