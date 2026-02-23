source "./source_urls.sh"

export SOURCE_URL=${JSONCPP_URL}
export MESON_FLAGS=""

source "../common/get_source.sh"

curl -JLO https://github.com/open-source-parsers/jsoncpp/commit/3d47db0edcfa5cb5a6237c43efbe443221a32702.patch?full_index=1
mv 3d47db0edcfa5cb5a6237c43efbe443221a32702.patch source
patch -d source/${SOURCE_FOLDER} < source/3d47db0edcfa5cb5a6237c43efbe443221a32702.patch

source "../common/meson_build.sh"