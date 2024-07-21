export SOURCE_URL="https://github.com/p11-glue/p11-kit/releases/download/0.25.5/p11-kit-0.25.5.tar.xz"
export MESON_FLAGS="-Dsystem_config=/usr/local/etc -Dmodule_config=/usr/local/etc/pkcs11/modules -Dtrust_paths=/usr/local/etc/ca-certificates/cert.pem  -Dsystemd=disabled"

source "../common/get_source.sh"
source "../common/meson_build.sh"