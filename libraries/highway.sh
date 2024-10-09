export SOURCE_URL="https://github.com/google/highway/archive/refs/tags/1.2.0.tar.gz"
export SOURCE_FILE="highway-1.2.0.tar.gz"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DHWY_ENABLE_TESTS=OFF -DHWY_ENABLE_EXAMPLES=OFF"

source "../common/get_source.sh"

cp highway.diff source
patch -d source/${SOURCE_FOLDER} < source/highway.diff 

source "../common/cmake_build.sh"