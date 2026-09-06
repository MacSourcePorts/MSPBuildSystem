# NOTE: Has an issue when installing, but libgnutls dylibs are stll installed. 
# Unsure if this is going to be an issue but moving on for now.

source "./source_urls.sh"

export SOURCE_URL=${GNUTLS_URL}
export CONFIGURE_ARGS=" --disable-dependency-tracking --disable-silent-rules --disable-static --with-default-trust-store-file=/usr/local/share/ca-certificates/cacert.pem --disable-heartbeat-support --with-p11-kit --sysconfdir=/usr/local/etc"

export RANLIB=/usr/bin/ranlib
export AR=/usr/bin/ar

source "../common/get_source.sh"

sudo install_name_tool -id "/usr/local/lib/libz.1.dylib" /usr/local/lib/libz.1.dylib
sudo install_name_tool -id "/usr/local/lib/libzstd.1.dylib" /usr/local/lib/libzstd.1.dylib

source "../common/make_build_lipo.sh"

sudo install_name_tool -id "@rpath/libz.1.dylib" /usr/local/lib/libz.1.dylib
sudo install_name_tool -id "@rpath/libzstd.1.dylib" /usr/local/lib/libzstd.1.dylib
# libbrotlienc

sudo install_name_tool -id "@rpath/libgnutls-dane.0.dylib" /usr/local/lib/libgnutls-dane.0.dylib
sudo install_name_tool -id "@rpath/libgnutls.30.dylib" /usr/local/lib/libgnutls.30.dylib
sudo install_name_tool -id "@rpath/libgnutlsxx.30.dylib" /usr/local/lib/libgnutlsxx.30.dylib

sudo install_name_tool -change /usr/local/lib/libgnutls.30.dylib @rpath/libgnutls.30.dylib /usr/local/lib/libgnutlsxx.30.dylib
sudo install_name_tool -change /usr/local/lib/libgnutls-dane.0.dylib @rpath/libgnutls-dane.0.dylib /usr/local/lib/libgnutlsxx.30.dylib
sudo install_name_tool -change /usr/local/lib/libgnutls.30.dylib @rpath/libgnutls.30.dylib /usr/local/lib/libgnutls-dane.0.dylib