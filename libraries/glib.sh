source "./source_urls.sh"

export glib_cv_long_double_math=no
export SOURCE_URL=${GLIB_URL}
export MESON_FLAGS="-Dintrospection=disabled -Ddefault_library=shared -Dbsymbolic_functions=false -Dtests=false -Dinstalled_tests=false"
export CROSS_FILE_X86_64="../../../glib-cross-x86_64.txt"
export MACOSX_DEPLOYMENT_TARGET="10.13"

source "../common/get_source.sh"
source "../common/meson_build.sh"