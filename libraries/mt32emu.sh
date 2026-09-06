source "./source_urls.sh"

export SOURCE_URL=${MT32EMU_URL}
export CMAKE_ARGS="-Dmunt_WITH_MT32EMU_QT=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"