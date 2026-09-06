source "./source_urls.sh"

export SOURCE_URL=${FREI0R_URL}
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DWITHOUT_OPENCV=ON -DWITHOUT_GAVL=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"