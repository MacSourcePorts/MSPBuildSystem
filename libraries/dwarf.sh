source "./source_urls.sh"

export SOURCE_URL=${DWARF_URL}

export CONFIGURE_ARGS="--enable-shared"

source "../common/get_source.sh"

# if [ -f source/${SOURCE_FOLDER}/Makefile ]; then
  gsed -E -i 's/-Wall/-Wall -Wno-incompatible-function-pointer-types/' source/${SOURCE_FOLDER}/src/Makefile
# fi

source "../common/make_build.sh"

sudo install_name_tool -id @rpath/libdwarf.2.dylib /usr/local/lib/libdwarf.2.dylib