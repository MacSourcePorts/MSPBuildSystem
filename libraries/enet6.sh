source "./source_urls.sh"

# ENet6 (KeeperFX) -- ENet with IPv6
export SOURCE_URL=${ENET6_URL}
export MACOSX_DEPLOYMENT_TARGET="10.14"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_NAME_DIR=@rpath"

source "../common/get_source.sh"
source "../common/cmake_build.sh"
