export SOURCE_URL="https://github.com/Haivision/srt/archive/refs/tags/v1.5.3.tar.gz"
export SOURCE_FILE="srt-1.5.3.tar.gz"
export CMAKE_ARGS="-DCMAKE_INSTALL_BINDIR=bin -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_INCLUDEDIR=include"

export OPENSSL_ROOT_DIR=/usr/local
export OPENSSL_LIBRARIES=/usr/local/lib
export C_INCLUDE_PATH=/usr/local/include
export LIBRARY_PATH=/usr/local/lib

source "../common/get_source.sh"
source "../common/cmake_build.sh"