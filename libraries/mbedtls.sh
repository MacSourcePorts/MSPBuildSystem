source "./source_urls.sh"

export SOURCE_URL=${MBEDTLS_URL}
export CMAKE_ARGS="-DUSE_SHARED_MBEDTLS_LIBRARY=On -DGEN_FILES=OFF"

source "../common/get_source.sh"

# enable pthread mutexes
gsed -i "s|//#define MBEDTLS_THREADING_PTHREAD *|#define MBEDTLS_THREADING_PTHREAD|" source/${SOURCE_FOLDER}/include/mbedtls/mbedtls_config.h
# allow use of mutexes within mbed TLS
gsed -i "s|//#define MBEDTLS_THREADING_C *|#define MBEDTLS_THREADING_C|" source/${SOURCE_FOLDER}/include/mbedtls/mbedtls_config.h
# enable DTLS-SRTP extension
gsed -i "s|//#define MBEDTLS_SSL_DTLS_SRTP *|#define MBEDTLS_SSL_DTLS_SRTP|" source/${SOURCE_FOLDER}/include/mbedtls/mbedtls_config.h

source "../common/cmake_build.sh"