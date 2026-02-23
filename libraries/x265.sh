source "./source_urls.sh"

export SOURCE_URL=${X265_URL}
export CMAKE_ARGS=""

source "../common/get_source.sh"

export SOURCE_FOLDER="${SOURCE_FOLDER}/source"

curl -JLO https://api.bitbucket.org/2.0/repositories/multicoreware/x265_git/diff/b354c009a60bcd6d7fc04014e200a1ee9c45c167
mv b354c009a60bcd6d7fc04014e200a1ee9c45c167 source
patch -d source/${SOURCE_FOLDER} < source/b354c009a60bcd6d7fc04014e200a1ee9c45c167

curl -JLO https://api.bitbucket.org/2.0/repositories/multicoreware/x265_git/diff/51ae8e922bcc4586ad4710812072289af91492a8
mv 51ae8e922bcc4586ad4710812072289af91492a8 source
patch -d source/${SOURCE_FOLDER} < source/51ae8e922bcc4586ad4710812072289af91492a8

source "../common/cmake_build.sh"