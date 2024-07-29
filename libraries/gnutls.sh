export SOURCE_URL="https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/gnutls-3.8.4.tar.xz"
export MAKE_ARGS=" --disable-dependency-tracking --disable-silent-rules --disable-static --with-default-trust-store-file=/usr/local/share/ca-certificates/cacert.pem --disable-heartbeat-support --with-p11-kit --sysconfdir=/usr/local/etc"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"