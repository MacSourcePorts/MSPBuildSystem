source "./source_urls.sh"

export SOURCE_URL=${AUTOMAKE_URL}

source "../common/get_source.sh"

cd source/${SOURCE_FOLDER}

./configure
make
sudo make install