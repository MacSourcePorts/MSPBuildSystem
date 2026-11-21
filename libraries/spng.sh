source "./source_urls.sh"

# libspng (KeeperFX)
export SOURCE_URL=${SPNG_URL}
export MACOSX_DEPLOYMENT_TARGET="10.14"
export CMAKE_ARGS="-DSPNG_STATIC=OFF -DBUILD_EXAMPLES=OFF -DCMAKE_PREFIX_PATH=/usr/local"

source "../common/get_source.sh"
source "../common/cmake_build.sh"
