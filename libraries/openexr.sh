export SOURCE_URL="https://github.com/AcademySoftwareFoundation/openexr/archive/refs/tags/v3.2.4.tar.gz"
export SOURCE_FILE="openexr-3.2.4.tar.gz"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9"

source "../common/get_source.sh"
source "../common/cmake_build.sh"