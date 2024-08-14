export SOURCE_URL="https://github.com/icculus/physfs/archive/refs/tags/release-3.2.0.tar.gz"
export SOURCE_FILE="physfs-release-3.2.0.tar.gz"
export CMAKE_ARGS="-DPHYSFS_BUILD_TEST=TRUE"

source "../common/get_source.sh"
source "../common/cmake_build.sh"