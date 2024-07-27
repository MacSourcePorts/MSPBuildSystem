export PATH=/usr/local/bin:$PATH:~/Library/Python/3.9/bin/
export SOURCE_URL="https://download.gnome.org/sources/gobject-introspection/1.80/gobject-introspection-1.80.1.tar.xz"
export MESON_FLAGS=""
export GI_SCANNER_DISABLE_CACHE=true

echo "*** we have to do a 'sudo' command up front that's why we need the password ***"

sudo install_name_tool -id "/usr/local/lib/libgio-2.0.0.dylib" /usr/local/lib/libgio-2.0.0.dylib
sudo install_name_tool -id "/usr/local/lib/libglib-2.0.0.dylib" /usr/local/lib/libglib-2.0.0.dylib
sudo install_name_tool -id "/usr/local/lib/libgmodule-2.0.0.dylib" /usr/local/lib/libgmodule-2.0.0.dylib
sudo install_name_tool -id "/usr/local/lib/libgobject-2.0.0.dylib" /usr/local/lib/libgobject-2.0.0.dylib

sudo install_name_tool -change @rpath/libglib-2.0.0.dylib /usr/local/lib/libglib-2.0.0.dylib /usr/local/lib/libgio-2.0.0.dylib
sudo install_name_tool -change @rpath/libgobject-2.0.0.dylib /usr/local/lib/libgobject-2.0.0.dylib /usr/local/lib/libgio-2.0.0.dylib
sudo install_name_tool -change @rpath/libgmodule-2.0.0.dylib /usr/local/lib/libgmodule-2.0.0.dylib /usr/local/lib/libgio-2.0.0.dylib

sudo install_name_tool -change @rpath/libglib-2.0.0.dylib /usr/local/lib/libglib-2.0.0.dylib /usr/local/lib/libgobject-2.0.0.dylib
sudo install_name_tool -change @rpath/libglib-2.0.0.dylib /usr/local/lib/libglib-2.0.0.dylib /usr/local/lib/libgmodule-2.0.0.dylib


source "../common/get_source.sh"

gsed -i "s|config.set_quoted('GOBJECT_INTROSPECTION_LIBDIR', join_paths(get_option('prefix'), get_option('libdir'))) *|config.set_quoted('GOBJECT_INTROSPECTION_LIBDIR', '/usr/local/lib')|" source/gobject-introspection-1.80.1/meson.build
gsed -i "s|/usr/share *|/usr/local/share|" source/gobject-introspection-1.80.1/giscanner/transformer.py

curl -JLO https://gitlab.gnome.org/tschoonj/gobject-introspection/-/commit/a7be304478b25271166cd92d110f251a8742d16b.diff
mv a7be304478b25271166cd92d110f251a8742d16b.diff source
patch -d source/${SOURCE_FOLDER} < source/a7be304478b25271166cd92d110f251a8742d16b.diff 

# source "../common/meson_build.sh"

if [ -z "${SOURCE_FOLDER}" ]; then
    cd source/${SOURCE_FILE}
else
    cd source/${SOURCE_FOLDER}
fi

meson setup builddir --prefix=/usr/local --libdir=lib --buildtype=release -Dc_args="-arch x86_64 -arch arm64" -Dc_link_args="-arch x86_64 -arch arm64" -Dpython=/usr/local/bin/python3 -Dextra_library_paths=/usr/local/lib
cd builddir
ninja
sudo ninja install

sudo install_name_tool -id "@rpath/libgio-2.0.0.dylib" /usr/local/lib/libgio-2.0.0.dylib
sudo install_name_tool -id "@rpath/libglib-2.0.0.dylib" /usr/local/lib/libglib-2.0.0.dylib
sudo install_name_tool -id "@rpath/libgmodule-2.0.0.dylib" /usr/local/lib/libgmodule-2.0.0.dylib
sudo install_name_tool -id "@rpath/libgobject-2.0.0.dylib" /usr/local/lib/libgobject-2.0.0.dylib

sudo install_name_tool -change /usr/local/lib/libglib-2.0.0.dylib @rpath/libglib-2.0.0.dylib /usr/local/lib/libgio-2.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libgobject-2.0.0.dylib @rpath/libgobject-2.0.0.dylib /usr/local/lib/libgio-2.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libgmodule-2.0.0.dylib @rpath/libgmodule-2.0.0.dylib /usr/local/lib/libgio-2.0.0.dylib

sudo install_name_tool -change /usr/local/lib/libglib-2.0.0.dylib @rpath/libglib-2.0.0.dylib /usr/local/lib/libgobject-2.0.0.dylib
sudo install_name_tool -change /usr/local/lib/libglib-2.0.0.dylib @rpath/libglib-2.0.0.dylib /usr/local/lib/libgmodule-2.0.0.dylib