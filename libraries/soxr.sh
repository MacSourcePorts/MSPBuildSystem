source "./source_urls.sh"

export SOURCE_URL=${SOXR_URL}
export CMAKE_ARGS="-DBUILD_TESTS=OFF -DBUILD_TESTING=OFF"
export CPPFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib -lomp"
source "../common/get_source.sh"

curl -JLO https://raw.githubusercontent.com/Homebrew/homebrew-core/1cf441a0/Patches/libsoxr/arm64_defines.patch
mv arm64_defines.patch source
patch -d source/${SOURCE_FOLDER} < source/arm64_defines.patch

source "../common/cmake_build.sh"