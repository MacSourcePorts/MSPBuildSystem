export SOURCE_URL="https://github.com/protocolbuffers/protobuf/releases/download/v33.2/protobuf-33.2.tar.gz"
export CMAKE_ARGS="-DCMAKE_CXX_STANDARD=17 -DBUILD_SHARED_LIBS=ON -Dprotobuf_BUILD_LIBPROTOC=ON -Dprotobuf_BUILD_SHARED_LIBS=ON -Dprotobuf_INSTALL_EXAMPLES=ON -Dprotobuf_BUILD_TESTS=ON -Dprotobuf_USE_EXTERNAL_GTEST=ON -Dprotobuf_FORCE_FETCH_DEPENDENCIES=OFF -Dprotobuf_LOCAL_DEPENDENCIES_ONLY=ON -Dprotobuf_BUILD_TESTS=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"