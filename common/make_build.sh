export MACOSX_DEPLOYMENT_TARGET="10.7"

if [ -z "${SOURCE_FILE}" ]; then
    SOURCE_FILE=${SOURCE_URL##*/}
fi

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

if [ -z "${SOURCE_FOLDER}" ]; then
    cd ${SOURCE_FILE}
else
    cd ${SOURCE_FOLDER}
fi


/usr/local/bin/gsed -i '/lame_init_old/d' include/libmp3lame.sym

./autogen.sh

echo ./configure CC="clang -arch arm64 -arch x86_64" \
    CXX="clang++ -arch arm64 -arch x86_64" \
    CPP="clang -E" CXXCPP="clang -E" \
    ${MAKE_ARGS}

./configure CC="clang -arch arm64 -arch x86_64" \
    CXX="clang++ -arch arm64 -arch x86_64" \
    CPP="clang -E" CXXCPP="clang -E" \
    ${MAKE_ARGS}
make
sudo make install