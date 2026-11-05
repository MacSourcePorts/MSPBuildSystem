source "./source_urls.sh"

export SOURCE_URL=${FLAC_URL}
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DINSTALL_MANPAGES=OFF"

source "../common/get_source.sh"

# FLAC 1.5.0's installed flac-config.cmake links Threads::Threads but never
# finds it, so consumers fail with "Threads::Threads ... target was not found"
CONFIG_IN=$(find source/${SOURCE_FOLDER} -maxdepth 2 -name flac-config.cmake.in | head -n1)
if [ -n "${CONFIG_IN}" ] && ! grep -q "find_dependency(Threads)" "${CONFIG_IN}"; then
	gsed -i 's|^include(CMakeFindDependencyMacro)$|include(CMakeFindDependencyMacro)\nfind_dependency(Threads)|' "${CONFIG_IN}"
fi
source "../common/cmake_build.sh"