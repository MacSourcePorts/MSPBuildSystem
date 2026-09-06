source "./source_urls.sh"

export SOURCE_URL=${OPENALSOFT_URL}
export CMAKE_ARGS="-DALSOFT_BACKEND_PORTAUDIO=OFF -DALSOFT_BACKEND_PULSEAUDIO=OFF -DALSOFT_EXAMPLES=OFF -DALSOFT_MIDI_FLUIDSYNTH=OFF -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13"

source "../common/get_source.sh"

curl -JLO https://github.com/kcat/openal-soft/commit/abd510d0aa7a27afc48af25c24ee6d6b544053cb.patch?full_index=1
mv abd510d0aa7a27afc48af25c24ee6d6b544053cb.patch source
patch -d source/${SOURCE_FOLDER} < source/abd510d0aa7a27afc48af25c24ee6d6b544053cb.patch

curl -JLO https://github.com/kcat/openal-soft/commit/b8c3593740630cdb3577fcb381e092898759064a.patch?full_index=1
mv b8c3593740630cdb3577fcb381e092898759064a.patch source
patch -d source/${SOURCE_FOLDER} < source/b8c3593740630cdb3577fcb381e092898759064a.patch


source "../common/cmake_build.sh"