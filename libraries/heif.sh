source "./source_urls.sh"

export SOURCE_URL=${HEIF_URL}
export CMAKE_ARGS="-DWITH_RAV1E=OFF -DWITH_DAV1D=OFF -DWITH_SvtEnc=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"