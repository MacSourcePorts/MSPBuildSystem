source "./source_urls.sh"

export SOURCE_URL=${PHYSFS_URL}
export CMAKE_ARGS="-DPHYSFS_BUILD_TEST=TRUE"

source "../common/get_source.sh"
source "../common/cmake_build.sh"