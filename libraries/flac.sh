export SOURCE_URL="https://ftp.osuosl.org/pub/xiph/releases/flac/flac-1.4.3.tar.xz"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DINSTALL_MANPAGES=OFF"

"../common/cmake_build.sh"