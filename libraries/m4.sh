source "./source_urls.sh"

export SOURCE_URL=${M4_URL}

source "../common/get_source.sh"

cd source/${SOURCE_FOLDER}

./configure
make
sudo make install
sudo install_name_tool -add_rpath /usr/local/lib/. /usr/local/bin/m4