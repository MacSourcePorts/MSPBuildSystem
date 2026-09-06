source "./source_urls.sh"

export SOURCE_URL=${VMAF_URL}
export SOURCE_DIR="libvmaf/"
export MESON_FLAGS=""

source "../common/get_source.sh"
source "../common/meson_build.sh"