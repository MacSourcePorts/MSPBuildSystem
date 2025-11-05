export SOURCE_URL="https://bitbucket.org/multicoreware/x265_git/get/3.6.tar.gz"
export SOURCE_FILE="multicoreware-x265_git-aa7f602f7592.tar.gz"
export SOURCE_FOLDER="multicoreware-x265_git-aa7f602f7592/source"
export CMAKE_ARGS=""

source "../common/get_source.sh"

curl -JLO https://api.bitbucket.org/2.0/repositories/multicoreware/x265_git/diff/b354c009a60bcd6d7fc04014e200a1ee9c45c167
mv b354c009a60bcd6d7fc04014e200a1ee9c45c167 source
patch -d source/${SOURCE_FOLDER} < source/b354c009a60bcd6d7fc04014e200a1ee9c45c167

curl -JLO https://api.bitbucket.org/2.0/repositories/multicoreware/x265_git/diff/51ae8e922bcc4586ad4710812072289af91492a8
mv 51ae8e922bcc4586ad4710812072289af91492a8 source
patch -d source/${SOURCE_FOLDER} < source/51ae8e922bcc4586ad4710812072289af91492a8


source "../common/cmake_build.sh"