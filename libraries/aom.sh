export CMAKE_ARGS="-DENABLE_DOCS=off -DENABLE_EXAMPLES=on -DENABLE_TESTDATA=off -DENABLE_TESTS=off -DENABLE_TOOLS=off -DBUILD_SHARED_LIBS=on -DCONFIG_TUNE_VMAF=1"
# todo: could these be standard?
export CMAKE_X86_64_ARGS="-DCMAKE_SYSTEM_NAME=Darwin -DCMAKE_SYSTEM_PROCESSOR=x86_64"
export SOURCE_FOLDER="aom"

rm -rf source
mkdir source
cd source
git clone --depth 1 --branch v3.9.1 https://aomedia.googlesource.com/aom.git
cd ..

source "../common/cmake_build_lipo.sh"