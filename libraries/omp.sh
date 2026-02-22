export SOURCE_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/openmp-18.1.8.src.tar.xz"
export CMAKE_ARGS="-DLLVM_ENABLE_RUNTIMES=openmp"
export SOURCE_FOLDER="llvm-project/runtimes"
export MACOSX_DEPLOYMENT_TARGET="10.15"

# as of 8/5/2024 the zipped entry above doesn't build. For now checking out the HEAD is easier. 
rm -rf source
mkdir source
cd source
git clone --depth 1 https://github.com/llvm/llvm-project.git
cd ..

# source "../common/get_source.sh"
source "../common/cmake_build.sh"