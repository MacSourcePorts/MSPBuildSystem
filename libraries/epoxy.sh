source "./source_urls.sh"

export SOURCE_URL=${EPOXY_URL}
export MESON_FLAGS=""

source "../common/get_source.sh"
source "../common/meson_build.sh"