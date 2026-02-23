source "./source_urls.sh"

export SOURCE_URL=${CPPUNIT_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking"

source "../common/get_source.sh"
source "../common/make_build.sh"