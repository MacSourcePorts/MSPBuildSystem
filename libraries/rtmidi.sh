source "./source_urls.sh"

export SOURCE_URL=${RTMIDI_URL}
export AUTOGEN_ARGS="--no-configure"

source "../common/get_source.sh"
source "../common/make_build.sh"