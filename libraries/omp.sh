export SOURCE_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/openmp-18.1.8.src.tar.xz"
export CMAKE_ARGS="-DLIBOMP_INSTALL_ALIASES=OFF"
export SOURCE_FOLDER="llvm-project/openmp"

# as of 8/5/2024 the zipped entry above doesn't build. For now checking out the HEAD is easier. 
rm -rf source
mkdir source
cd source
git clone --depth 1 https://github.com/llvm/llvm-project.git
cd ..

# source "../common/get_source.sh"
source "../common/cmake_build.sh"