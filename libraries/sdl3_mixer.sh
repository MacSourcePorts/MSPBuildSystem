source "./source_urls.sh"

# SDL3_mixer (KeeperFX, Dune II - The Maker) -- the built-in decoders
# (stb_vorbis, dr_flac, dr_mp3, timidity), so it pulls no other libraries
# into the games' bundles, plus FluidSynth for MIDI (D2TM). FluidSynth is
# loaded at run time (dlopen of libfluidsynth.3.dylib, SDLMIXER_DEPS_SHARED),
# not linked: a game that wants MIDI bundles libfluidsynth itself, the others
# are unaffected.
export SOURCE_URL=${SDL3_MIXER_URL}
export MACOSX_DEPLOYMENT_TARGET="10.14"
export CMAKE_ARGS="-DSDLMIXER_VENDORED=OFF -DSDLMIXER_TESTS=OFF -DSDLMIXER_EXAMPLES=OFF -DSDLMIXER_GME=OFF -DSDLMIXER_MOD_XMP=OFF -DSDLMIXER_OPUS=OFF -DSDLMIXER_VORBIS_VORBISFILE=OFF -DSDLMIXER_WAVPACK=OFF -DSDLMIXER_FLAC_LIBFLAC=OFF -DSDLMIXER_MP3_MPG123=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"
