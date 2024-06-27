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
cd ${SOURCE_FILE}

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