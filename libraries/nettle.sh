# Note: not building at the moment.

source "./source_urls.sh"

export SOURCE_URL=${NETTLE_URL}
export CONFIGURE_ARGS="--enable-shared"

export RANLIB=/usr/bin/ranlib
export AR=/usr/bin/ar

sudo install_name_tool -id "/usr/local/lib/libgmp.10.dylib" /usr/local/lib/libgmp.10.dylib

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"

sudo install_name_tool -id "@rpath/libgmp.10.dylib" /usr/local/lib/libgmp.10.dylib

# Give nettle/hogweed @rpath ids and fix their references, whatever version was just installed
# (nettle 3.x = libnettle.8 / libhogweed.6, nettle 4.x = libnettle.9 / libhogweed.7)
for LIB in libnettle libhogweed; do
    LIB_FILE=/usr/local/lib/$(readlink /usr/local/lib/${LIB}.dylib)
    OLD_ID=$(otool -D ${LIB_FILE} | tail -1)
    sudo install_name_tool -id "@rpath/$(basename ${OLD_ID})" ${LIB_FILE}
done
HOGWEED_FILE=/usr/local/lib/$(readlink /usr/local/lib/libhogweed.dylib)
for DEP in $(otool -L ${HOGWEED_FILE} | awk '/\/usr\/local\/lib\//{print $1}'); do
    sudo install_name_tool -change ${DEP} "@rpath/$(basename ${DEP})" ${HOGWEED_FILE}
done
