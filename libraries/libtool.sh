source "./source_urls.sh"

export SOURCE_URL=${LIBTOOL_URL}
export CONFIGURE_ARGS="--prefix=/usr/local --disable-dependency-tracking --disable-silent-rules --enable-ltdl-install"
export SED="sed"

source "../common/get_source.sh"
source "../common/make_build_lipo.sh"