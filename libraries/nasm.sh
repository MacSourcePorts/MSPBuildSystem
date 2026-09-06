source "./source_urls.sh"

export SOURCE_URL=${NASM_URL}

source "../common/get_source.sh"
source "../common/make_build.sh"
sudo install_name_tool -add_rpath /usr/local/lib/. /usr/local/bin/nasm