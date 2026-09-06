source "./source_urls.sh"

export SOURCE_URL=${IDN_URL}
export CONFIGURE_ARGS="--disable-dependency-tracking --disable-csharp"

source "../common/get_source.sh"
source "../common/make_build.sh"