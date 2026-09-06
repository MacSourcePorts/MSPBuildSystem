source "./source_urls.sh"

export SOURCE_URL=${AUTOCONFARCHIVE_URL}
# export SOURCE_FOLDER="DevIL"
export CMAKE_ARGS=""

source "../common/get_source.sh"

curl -JLO https://github.com/autoconf-archive/autoconf-archive/commit/fadde164479a926d6b56dd693ded2a4c36ed89f0.patch?full_index=1
mv fadde164479a926d6b56dd693ded2a4c36ed89f0.patch source
patch -d source/${SOURCE_FOLDER} < source/fadde164479a926d6b56dd693ded2a4c36ed89f0.patch

source "../common/make_build.sh"

sudo install_name_tool -id "@rpath/libIL.dylib" /usr/local/lib/libIL.dylib