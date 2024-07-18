export SOURCE_URL="https://github.com/AcademySoftwareFoundation/Imath/archive/refs/tags/v3.1.11.tar.gz"
export SOURCE_FILE="Imath-3.1.11.tar.gz"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"