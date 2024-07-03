export SOURCE_URL="https://files.portaudio.com/archives/pa_stable_v190700_20210406.tgz"
export SOURCE_FOLDER="portaudio"
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DINSTALL_MANPAGES=OFF"

"../common/cmake_build.sh"