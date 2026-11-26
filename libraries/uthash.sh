source "./source_urls.sh"

# uthash (TRX) -- header-only, with no build system: the headers are copied
# into /usr/local/include
export SOURCE_URL=${UTHASH_URL}

source "../common/get_source.sh"

sudo install -m 644 source/${SOURCE_FOLDER}/src/*.h /usr/local/include/
