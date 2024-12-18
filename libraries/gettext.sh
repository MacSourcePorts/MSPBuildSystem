# Note: has build issues but still installs dylibs, moving on for now

export SOURCE_URL="https://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
export CONFIGURE_ARGS="--disable-static --enable-shared --disable-silent-rules --with-included-glib --with-included-libcroco --with-included-libunistring --with-included-libxml --with-emacs --disable-java --disable-csharp --without-git --without-cvs --without-xz --with-included-gettext"

export RANLIB=/usr/bin/ranlib
export AR=/usr/bin/ar

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"

sudo install_name_tool -id "@rpath/libintl.8.dylib" /usr/local/lib/libintl.8.dylib
sudo install_name_tool -id "@rpath/libasprintf.0.dylib" /usr/local/lib/libasprintf.0.dylib
sudo install_name_tool -id "@rpath/libtextstyle.0.dylib" /usr/local/lib/libtextstyle.0.dylib
sudo install_name_tool -id "@rpath/libgettextlib-0.22.5.dylib" /usr/local/lib/libgettextlib-0.22.5.dylib
sudo install_name_tool -id "@rpath/libgettextsrc-0.22.5.dylib" /usr/local/lib/libgettextsrc-0.22.5.dylib
sudo install_name_tool -id "@rpath/libgettextpo.0.dylib" /usr/local/lib/libgettextpo.0.dylib

sudo install_name_tool -change /usr/local/lib/libintl.8.dylib @rpath/libintl.8.dylib /usr/local/lib/libgettextlib-0.22.5.dylib
sudo install_name_tool -change /usr/local/lib/libgettextlib-0.22.5.dylib @rpath/libgettextlib-0.22.5.dylib /usr/local/lib/libgettextsrc-0.22.5.dylib
sudo install_name_tool -change /usr/local/lib/libintl.8.dylib @rpath/libintl.8.dylib /usr/local/lib/libgettextsrc-0.22.5.dylib
sudo install_name_tool -change /usr/local/lib/libtextstyle.0.dylib @rpath/libtextstyle.0.dylib /usr/local/lib/libgettextsrc-0.22.5.dylib
sudo install_name_tool -change /usr/local/lib/libintl.8.dylib @rpath/libintl.8.dylib /usr/local/lib/libgettextpo.0.dylib