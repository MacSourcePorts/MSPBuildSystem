export SOURCE_URL="https://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.gz"
export MAKE_ARGS="--disable-static --enable-shared --disable-silent-rules --with-included-glib --with-included-libcroco --with-included-libunistring --with-included-libxml --with-emacs --disable-java --disable-csharp --without-git --without-cvs --without-xz --with-included-gettext"

"../common/make_build.sh"