source "./source_urls.sh"

export SOURCE_URL=${SAMPLERATE_URL}
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DLIBSAMPLERATE_EXAMPLES=OFF -DBUILD_TESTING=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"