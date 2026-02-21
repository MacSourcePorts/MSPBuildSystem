export SOURCE_URL="https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz"
export CFLAGS="-Wno-int-conversion"
export CXXFLAGS="-Wno-int-conversion"
export LDFLAGS="-framework CoreFoundation -framework Carbon"

export CONFIGURE_ARGS="--with-internal-glib"

source "../common/get_source.sh"
source "../common/make_build.sh"