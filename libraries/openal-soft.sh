export SOURCE_URL="https://openal-soft.org/openal-releases/openal-soft-1.23.1.tar.bz2"
export CMAKE_ARGS="-DALSOFT_BACKEND_PORTAUDIO=OFF -DALSOFT_BACKEND_PULSEAUDIO=OFF -DALSOFT_EXAMPLES=OFF -DALSOFT_MIDI_FLUIDSYNTH=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"