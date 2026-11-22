source "./source_urls.sh"

# SDL3_ttf (Dune II - The Maker) -- against the freetype already in /usr/local
# rather than its vendored copy. No harfbuzz (complex text shaping, which
# would pull glib, pcre2, gettext and graphite2 into the games' bundles) and
# no SVG glyphs (plutosvg).
export SOURCE_URL=${SDL3_TTF_URL}
export MACOSX_DEPLOYMENT_TARGET="11.0"
export CMAKE_ARGS="-DSDLTTF_VENDORED=OFF -DSDLTTF_SAMPLES=OFF -DSDLTTF_TESTS=OFF -DSDLTTF_HARFBUZZ=OFF -DSDLTTF_PLUTOSVG=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"
