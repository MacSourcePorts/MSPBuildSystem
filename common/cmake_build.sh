export MACOSX_DEPLOYMENT_TARGET="10.7"
SOURCE_FILE=${SOURCE_URL##*/}

rm -rf source
mkdir source
cd source
curl -JLO ${SOURCE_URL}
if [[ ${SOURCE_URL} == *.zip ]]; then
    unzip ${SOURCE_FILE}
    SOURCE_FILE=${SOURCE_FILE%.*}
else
    tar -xzvf ${SOURCE_FILE}
    SOURCE_FILE=${SOURCE_FILE%.*.*}
fi


cd ..
rm -rf build
mkdir build
cd build
cmake ../source/${SOURCE_FILE} "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" ${CMAKE_ARGS}
cmake --build .
sudo cmake --install .