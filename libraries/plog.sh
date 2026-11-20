source "./source_urls.sh"

# plog logging library (Descent3) -- header-only
export SOURCE_URL=${PLOG_URL}
export CMAKE_ARGS="-DPLOG_BUILD_SAMPLES=OFF -DPLOG_BUILD_TESTS=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"
