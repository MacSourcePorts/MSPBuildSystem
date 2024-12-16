# Note: has build issues but still installs dylibs, moving on for now

export SOURCE_URL="https://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
export CONFIGURE_ARGS="--disable-static --enable-shared --disable-silent-rules --with-included-glib --with-included-libcroco --with-included-libunistring --with-included-libxml --with-emacs --disable-java --disable-csharp --without-git --without-cvs --without-xz --with-included-gettext"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libintl.8.dylib" /usr/local/lib/libintl.8.dylib
sudo install_name_tool -id "@rpath/libasprintf.0.dylib" /usr/local/lib/libasprintf.0.dylib