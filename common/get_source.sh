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