source "./source_urls.sh"

# libcurl (KeeperFX's multiplayer matchmaking needs WebSockets, which the
# macOS system libcurl doesn't have). OpenSSL for TLS, verified against the
# macOS keychain (Apple SecTrust) so no CA bundle has to be shipped. No
# optional extras, so it pulls nothing else into the games' bundles.
export SOURCE_URL=${CURL_URL}
export MACOSX_DEPLOYMENT_TARGET="10.14"
export CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/usr/local -DCMAKE_INSTALL_NAME_DIR=@rpath \
-DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF -DBUILD_CURL_EXE=OFF -DBUILD_TESTING=OFF -DBUILD_LIBCURL_DOCS=OFF -DBUILD_MISC_DOCS=OFF -DENABLE_CURL_MANUAL=OFF \
-DCURL_USE_OPENSSL=ON -DOPENSSL_ROOT_DIR=/usr/local -DUSE_APPLE_SECTRUST=ON \
-DCURL_USE_LIBPSL=OFF -DUSE_LIBIDN2=OFF -DUSE_NGHTTP2=OFF -DCURL_USE_LIBSSH2=OFF -DCURL_BROTLI=OFF -DCURL_ZSTD=OFF -DCURL_DISABLE_LDAP=ON -DUSE_APPLE_IDN=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"
