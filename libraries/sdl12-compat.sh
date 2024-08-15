export SOURCE_URL="https://github.com/libsdl-org/sdl12-compat/archive/refs/tags/release-1.2.68.tar.gz"
export SOURCE_FILE="sdl12-compat-release-1.2.68.tar.gz"
export CMAKE_ARGS="-DSDL12DEVEL=ON -DSDL12TESTS=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"

sudo ln -s /usr/local/lib/pkgconfig/sdl12_compat.pc /usr/local/lib/pkgconfig/sdl.pc