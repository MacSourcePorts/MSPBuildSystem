export SOURCE_URL="https://github.com/open-source-parsers/jsoncpp/archive/refs/tags/1.9.6.tar.gz"
export SOURCE_FILE="jsoncpp-1.9.6.tar.gz"
export MESON_FLAGS=""

source "../common/get_source.sh"

curl -JLO https://github.com/open-source-parsers/jsoncpp/commit/3d47db0edcfa5cb5a6237c43efbe443221a32702.patch?full_index=1
mv 3d47db0edcfa5cb5a6237c43efbe443221a32702.patch source
patch -d source/${SOURCE_FOLDER} < source/3d47db0edcfa5cb5a6237c43efbe443221a32702.patch

source "../common/meson_build.sh"