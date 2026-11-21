source "./source_urls.sh"

# SDL3_image (KeeperFX) -- only the built-in codecs (ImageIO/stb), so it pulls
# no other libraries into the games' bundles
export SOURCE_URL=${SDL3_IMAGE_URL}
export MACOSX_DEPLOYMENT_TARGET="10.14"
export CMAKE_ARGS="-DSDLIMAGE_VENDORED=OFF -DSDLIMAGE_SAMPLES=OFF -DSDLIMAGE_TESTS=OFF -DSDLIMAGE_AVIF=OFF -DSDLIMAGE_JXL=OFF -DSDLIMAGE_TIF=OFF -DSDLIMAGE_WEBP=OFF -DSDLIMAGE_PNG_LIBPNG=OFF"

source "../common/get_source.sh"
source "../common/cmake_build.sh"
