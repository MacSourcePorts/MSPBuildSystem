export MACOSX_DEPLOYMENT_TARGET="10.7"

if [ -z "${SOURCE_FOLDER}" ]; then
    cd source/${SOURCE_FILE}
else
    cd source/${SOURCE_FOLDER}
fi

./autogen.sh
./bootstrap

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