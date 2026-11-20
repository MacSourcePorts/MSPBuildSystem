source "./source_urls.sh"

# cpp-httplib (Descent3) -- header-only, without the optional OpenSSL and
# compression backends so nothing extra gets pulled into the games' bundles
export SOURCE_URL=${CPPHTTPLIB_URL}
export CMAKE_ARGS="-DHTTPLIB_COMPILE=OFF -DHTTPLIB_TEST=OFF -DHTTPLIB_USE_OPENSSL_IF_AVAILABLE=OFF -DHTTPLIB_USE_ZLIB_IF_AVAILABLE=OFF -DHTTPLIB_USE_BROTLI_IF_AVAILABLE=OFF -DHTTPLIB_USE_ZSTD_IF_AVAILABLE=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"
