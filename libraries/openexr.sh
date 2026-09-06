source "./source_urls.sh"

export SOURCE_URL=${OPENEXR_URL}
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15"

source "../common/get_source.sh"
source "../common/cmake_build.sh"