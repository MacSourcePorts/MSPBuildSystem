source "./source_urls.sh"

export SOURCE_URL=${FLAC_URL}
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DINSTALL_MANPAGES=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"