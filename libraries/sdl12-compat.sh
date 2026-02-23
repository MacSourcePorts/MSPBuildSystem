source "./source_urls.sh"

export SOURCE_URL=${SDL12COMPAT_URL}
export CMAKE_ARGS="-DSDL12DEVEL=ON -DSDL12TESTS=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"

sudo ln -s /usr/local/lib/pkgconfig/sdl12_compat.pc /usr/local/lib/pkgconfig/sdl.pc