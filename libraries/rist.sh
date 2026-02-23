source "./source_urls.sh"

export SOURCE_URL=${RIST_URL}
export MESON_FLAGS="--default-library both -Dfallback_builtin=false"

source "../common/get_source.sh"

# todo: learn more gsed
gsed -i "s|buf.st_mtim.tv_sec*|buf.st_mtimespec.tv_sec|" source/librist-v0.2.10/tools/srp_shared.c
gsed -i "s|buf.st_mtim.tv_nsec*|buf.st_mtimespec.tv_nsec|" source/librist-v0.2.10/tools/srp_shared.c

source "../common/meson_build.sh"