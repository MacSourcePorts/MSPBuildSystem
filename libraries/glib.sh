export SOURCE_URL="https://download.gnome.org/sources/glib/2.80/glib-2.80.3.tar.xz"
export MESON_FLAGS="-Dintrospection=disabled -Dbsymbolic_functions=false -Dbsymbolic_functions=false -Dtests=false"

source "../common/get_source.sh"
source "../common/meson_build.sh"