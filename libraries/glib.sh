export glib_cv_long_double_math=no
export SOURCE_URL="https://download.gnome.org/sources/glib/2.80/glib-2.80.3.tar.xz"
export MESON_FLAGS="-Dintrospection=disabled -Ddefault_library=shared -Dbsymbolic_functions=false -Dtests=false -Dinstalled_tests=false"
export CROSS_FILE_X86_64="../../../glib-cross-x86_64.txt"

source "../common/get_source.sh"
source "../common/meson_build.sh"