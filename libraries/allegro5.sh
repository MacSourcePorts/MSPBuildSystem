source "./source_urls.sh"

# Allegro 5 (Dune Dynasty) -- the core plus the addons it uses (audio, acodec,
# image, memfile, primitives, main). Images load through macOS's own image
# loader; acodec links the FLAC and Ogg Vorbis libraries already in /usr/local
# (not dlopen'd, so copy_dependencies bundles them). Fonts, TTF, dialogs,
# video, PhysFS, Opus and tracker formats are off, so they pull nothing else
# into the games' bundles.
export SOURCE_URL=${ALLEGRO5_URL}
export SOURCE_FOLDER="allegro-5.2.11.3"
export MACOSX_DEPLOYMENT_TARGET="11.0"
export CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release -DSHARED=ON -DWANT_DOCS=OFF -DWANT_EXAMPLES=OFF -DWANT_TESTS=OFF -DWANT_DEMO=OFF -DWANT_POPUP_EXAMPLES=OFF -DWANT_FONT=OFF -DWANT_TTF=OFF -DWANT_NATIVE_DIALOG=OFF -DWANT_VIDEO=OFF -DWANT_PHYSFS=OFF -DWANT_COLOR=OFF -DWANT_OPUS=OFF -DWANT_MODAUDIO=OFF -DWANT_OPENMPT=OFF -DWANT_IMAGE_WEBP=OFF -DWANT_IMAGE_JXL=OFF -DWANT_IMAGE_FREEIMAGE=OFF -DWANT_ACODEC_DYNAMIC_LOAD=OFF -DWANT_FLAC=ON -DWANT_VORBIS=ON"

source "../common/get_source.sh"

# A fullscreen window (ALLEGRO_FULLSCREEN_WINDOW) stays below a MacBook's
# camera notch, with the strip beside it blacked out, instead of putting the
# top of the picture behind it
patch -p1 -d source/${SOURCE_FOLDER} < allegro5.diff
source "../common/cmake_build.sh"
