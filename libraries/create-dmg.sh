source "./source_urls.sh"

export SOURCE_URL=${CREATEDMG_URL}

source "../common/get_source.sh"

cd source/${SOURCE_FOLDER}

sudo make install