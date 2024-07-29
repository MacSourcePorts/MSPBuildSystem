export SOURCE_URL="https://www.libssh.org/files/0.10/libssh-0.10.6.tar.xz"
export CMAKE_ARGS="-DBUILD_STATIC_LIB=ON -DWITH_SYMBOL_VERSIONING=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"