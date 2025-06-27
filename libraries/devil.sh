export SOURCE_URL="https://downloads.sourceforge.net/project/openil/DevIL/1.8.0/DevIL-1.8.0.tar.gz"
export SOURCE_FOLDER="DevIL"
export CMAKE_ARGS=""

source "../common/get_source.sh"

curl -JLO https://github.com/DentonW/DevIL/commit/41fcabbe.patch?full_index=1
mv 41fcabbe.patch source
patch -d source/${SOURCE_FOLDER} < source/41fcabbe.patch

curl -JLO https://github.com/DentonW/DevIL/commit/4a2d7822.patch?full_index=1
mv 4a2d7822.patch source
patch -d source/${SOURCE_FOLDER} < source/4a2d7822.patch

# curl -JLO https://github.com/DentonW/DevIL/commit/42a62648.patch?full_index=1
# mv 42a62648.patch source
# patch -d source/${SOURCE_FOLDER} < source/42a62648.patch

gsed -i 's/static int iJp2_file_read(jas_stream_obj_t \*obj, char \*buf, int cnt)/static ssize_t iJp2_file_read(jas_stream_obj_t \*obj, char \*buf, size_t cnt)/' source/DevIL/DevIL/src-IL/src/il_jp2.cpp
gsed -i 's/static int iJp2_file_write(jas_stream_obj_t \*obj, char \*buf, int cnt)/static ssize_t iJp2_file_write(jas_stream_obj_t \*obj, const char \*buf, size_t cnt)/' source/DevIL/DevIL/src-IL/src/il_jp2.cpp

export SOURCE_FOLDER="DevIL/DevIL"

source "../common/cmake_build.sh"

sudo install_name_tool -id "@rpath/libIL.dylib" /usr/local/lib/libIL.dylib