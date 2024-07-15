export MACOSX_DEPLOYMENT_TARGET="10.7"
export NCPU=`sysctl -n hw.ncpu`

if [ -z "${SOURCE_FILE}" ]; then
    SOURCE_FILE=${SOURCE_URL##*/}
fi

rm -rf source
mkdir source
cd source
curl -JLO ${SOURCE_URL}

if [[ ${SOURCE_URL} == *.zip ]]; then
    unzip ${SOURCE_FILE}
    if [ -z "${SOURCE_FOLDER}" ]; then
        SOURCE_FOLDER=${SOURCE_FILE%.*}
    fi
else
    tar -xzvf ${SOURCE_FILE}
    if [ -z "${SOURCE_FOLDER}" ]; then
        SOURCE_FOLDER=${SOURCE_FILE%.*.*}
    fi
fi


cd ..
rm -rf build
mkdir build
cd build
cmake ../source/${SOURCE_FOLDER} "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" ${CMAKE_ARGS}
cmake --build . --parallel $NCPU
sudo cmake --install .