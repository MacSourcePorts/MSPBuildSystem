source "./source_urls.sh"

export SOURCE_URL=${VIDSTAB_URL}
export CMAKE_ARGS="-DUSE_OMP=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"

sudo install_name_tool -id "@rpath/libvidstab.1.2.dylib" /usr/local/lib/libvidstab.1.2.dylib