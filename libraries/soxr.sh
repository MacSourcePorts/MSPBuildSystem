export SOURCE_URL="https://downloads.sourceforge.net/project/soxr/soxr-0.1.3-Source.tar.xz"
export CMAKE_ARGS=""

source "../common/get_source.sh"

curl -JLO https://raw.githubusercontent.com/Homebrew/formula-patches/76868b36263be42440501d3692fd3a258f507d82/libsoxr/arm64_defines.patch
mv arm64_defines.patch source
patch -d source/${SOURCE_FOLDER} < source/arm64_defines.patch

source "../common/cmake_build.sh"