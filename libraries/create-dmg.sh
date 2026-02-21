export SOURCE_URL="https://github.com/create-dmg/create-dmg/archive/refs/tags/v1.2.3.zip"
export SOURCE_FILE="create-dmg-1.2.3.zip"

source "../common/get_source.sh"

cd source/${SOURCE_FOLDER}

sudo make install