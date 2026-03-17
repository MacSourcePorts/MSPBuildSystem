source "./source_urls.sh"

export SOURCE_URL=${PORTAUDIO_URL}
export SOURCE_FOLDER="portaudio"
# export CMAKE_ARGS="-DBUILD_SHARED_LIBS=ON -DINSTALL_MANPAGES=OFF"
export CONFIGURE_ARGS="--enable-cxx"

source "../common/get_source.sh"

echo $PWD
sed -i '' 's/-Werror//g' source/portaudio/configure

source "../common/make_build.sh"