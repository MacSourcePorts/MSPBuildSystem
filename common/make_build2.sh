export MACOSX_DEPLOYMENT_TARGET="10.7"

if [ -z "${SOURCE_FOLDER}" ]; then
    cd source/${SOURCE_FILE}
else
    cd source/${SOURCE_FOLDER}
fi

./configure ${CONFIGURE_ARGS}

(CFLAGS="-arch arm64 -arch x86_64" CPPFLAGS="-arch arm64 -arch x86_64" LDFLAGS="-arch arm64 -arch x86_64" make)
sudo make install