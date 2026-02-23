source "./source_urls.sh"

export SOURCE_URL=${FLUIDSYNTH_URL}
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -Denable-alsa=OFF -Denable-aufile=ON -Denable-coverage=OFF -Denable-coreaudio=ON -Denable-coremidi=ON -Denable-dart=OFF -Denable-dbus=OFF -Denable-dsound=OFF -Denable-floats=OFF -Denable-fpe-check=OFF -Denable-framework=OFF -Denable-ipv6=ON -Denable-jack=OFF -Denable-ladspa=OFF -Denable-lash=OFF -Denable-libinstpatch=OFF -Denable-libsndfile=ON -Denable-midishare=OFF -Denable-network=ON -Denable-opensles=OFF -Denable-oboe=OFF -Denable-openmp=OFF -Denable-oss=OFF -Denable-pipewire=OFF -Denable-portaudio=ON -Denable-profiling=OFF -Denable-pulseaudio=OFF -Denable-readline=ON -Denable-sdl2=OFF -Denable-systemd=OFF -Denable-trap-on-fpe=OFF -Denable-threads=ON -Denable-ubsan=OFF -Denable-wasapi=OFF -Denable-waveout=OFF -Denable-winmidi=OFF"

source "../common/get_source.sh"

if [ -f source/${SOURCE_FOLDER}/src/gentables/CMakeLists.txt ]; then
  gsed -E -i 's/^cmake_minimum_required[[:space:]]*\(VERSION[[:space:]]*([0-9.]+)\)/cmake_minimum_required(VERSION \1...3.31)/' source/fluidsynth-2.3.5/src/gentables/CMakeLists.txt
fi

source "../common/cmake_build.sh"

sudo install_name_tool -id "@rpath/libfluidsynth.3.dylib" /usr/local/lib/libfluidsynth.3.dylib