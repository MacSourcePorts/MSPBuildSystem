export SOURCE_URL="https://github.com/strukturag/libheif/releases/download/v1.18.1/libheif-1.18.1.tar.gz"
export CMAKE_ARGS="-DWITH_RAV1E=OFF -DWITH_DAV1D=OFF -DWITH_SvtEnc=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"