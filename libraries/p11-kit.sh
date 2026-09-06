source "./source_urls.sh"

export SOURCE_URL=${P11KIT_URL}
export MESON_FLAGS="-Dsystem_config=/usr/local/etc -Dmodule_config=/usr/local/etc/pkcs11/modules -Dtrust_paths=/usr/local/etc/ca-certificates/cert.pem  -Dsystemd=disabled"

source "../common/get_source.sh"
source "../common/meson_build.sh"