export SOURCE_URL="https://distfiles.gentoo.org/distfiles/08/openal-soft-1.24.3.tar.bz2"
export CMAKE_ARGS="-DALSOFT_BACKEND_PORTAUDIO=OFF -DALSOFT_BACKEND_PULSEAUDIO=OFF -DALSOFT_EXAMPLES=OFF -DALSOFT_MIDI_FLUIDSYNTH=OFF -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13"

source "../common/get_source.sh"
source "../common/cmake_build.sh"