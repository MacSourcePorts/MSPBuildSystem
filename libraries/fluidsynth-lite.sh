set -e
export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DCMAKE_MACOSX_RPATH=ON"
export SOURCE_FOLDER="fluidsynth-lite"
export MACOSX_DEPLOYMENT_TARGET="10.12"

# TODO: make the "git clone" bit be in a /common/ script.
rm -rf source
mkdir source
cd source
git clone https://github.com/EtherTyper/fluidsynth-lite.git
cd $SOURCE_FOLDER

gsed -i "s|info->assigned = TRUE|info->assigned = true|" src/synth/fluid_synth.c
gsed -i "s|info->assigned = FALSE|info->assigned = false|" src/synth/fluid_synth.c
gsed -i "s|int count = 0;|//int count = 0;|" src/midi/fluid_seq.c
gsed -i "s|count++;|//count++;|" src/midi/fluid_seq.c
gsed -i "s|    count = 0;|    //count = 0;|" src/midi/fluid_seq.c

cd ../..

source "../common/cmake_build.sh"