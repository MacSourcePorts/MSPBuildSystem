source "./source_urls.sh"

export SOURCE_URL=${PKGCONF_URL}
export CFLAGS="-Wno-int-conversion"
export CXXFLAGS="-Wno-int-conversion"
export LDFLAGS="-framework CoreFoundation -framework Carbon"

export CONFIGURE_ARGS="--with-internal-glib"

source "../common/get_source.sh"
source "../common/make_build.sh"