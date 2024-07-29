export SOURCE_URL="https://github.com/Mbed-TLS/mbedtls/releases/download/v3.6.0/mbedtls-3.6.0.tar.bz2"
export CMAKE_ARGS="-DUSE_SHARED_MBEDTLS_LIBRARY=On -DGEN_FILES=OFF"

source "../common/get_source.sh"

# enable pthread mutexes
gsed -i "s|//#define MBEDTLS_THREADING_PTHREAD *|#define MBEDTLS_THREADING_PTHREAD|" source/mbedtls-3.6.0/include/mbedtls/mbedtls_config.h
# allow use of mutexes within mbed TLS
gsed -i "s|//#define MBEDTLS_THREADING_C *|#define MBEDTLS_THREADING_C|" source/mbedtls-3.6.0/include/mbedtls/mbedtls_config.h
# enable DTLS-SRTP extension
gsed -i "s|//#define MBEDTLS_SSL_DTLS_SRTP *|#define MBEDTLS_SSL_DTLS_SRTP|" source/mbedtls-3.6.0/include/mbedtls/mbedtls_config.h

source "../common/cmake_build.sh"