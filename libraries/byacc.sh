source "./source_urls.sh"

# Berkeley yacc -- civctp2's build insists on byacc rather than bison's yacc
export SOURCE_URL=${BYACC_URL}
export CONFIGURE_ARGS="--program-prefix=b"

source "../common/get_source.sh"
source "../common/make_build.sh"
