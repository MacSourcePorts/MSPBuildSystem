export SOURCE_URL="https://imagemagick.org/archive/releases/ImageMagick-7.1.1-44.tar.xz"
export CONFIGURE_ARGS="--enable-osx-universal-binary=no --disable-silent-rules --disable-opencl --enable-shared --enable-static --with-freetype=yes --with-gvc=no --with-modules --with-openjp2 --with-openexr --with-webp=yes --with-heic=yes --with-raw=yes --with-gslib --with-gs-font-dir=/usr/local/share/ghostscript/fonts --without-lqr --without-djvu --without-fftw --without-pango --without-wmf --enable-openmp --without-x ac_cv_prog_c_openmp=-Xpreprocessor -fopenmp ac_cv_prog_cxx_openmp=-Xpreprocessor -fopenmp LDFLAGS=-lomp -lz"
export CONFIGURE_ARGS="--enable-osx-universal-binary=no --disable-silent-rules --disable-opencl --enable-shared --enable-static --with-freetype=yes --with-gvc=no --with-modules --with-openjp2 --with-openexr --with-webp=yes --with-heic=yes --with-raw=yes --with-gslib --with-gs-font-dir=/usr/local/share/ghostscript/fonts --without-lqr --without-djvu --without-fftw --without-pango --without-wmf --enable-openmp --without-x LDFLAGS=-lomp --prefix=/usr/local/"

# CXX="/usr/local/bin/g++-14"
# CC="/usr/local/bin/gcc-14"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"

sudo install_name_tool -add_rpath /usr/local/lib /usr/local/bin/magick