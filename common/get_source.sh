rm -rf source
mkdir source
cd source

curl -JLO ${SOURCE_URL}

if [ -z "${SOURCE_FILE}" ]; then
    # SOURCE_FILE=${SOURCE_URL##*/}
    SOURCE_FILE=$(ls -t | head -n1)
fi

if [[ ${SOURCE_URL} == *.zip ]]; then
    yes | unzip ${SOURCE_FILE}
    if [ -z "${SOURCE_FOLDER}" ]; then
        SOURCE_FOLDER=${SOURCE_FILE%.*}
    fi
elif [[ ${SOURCE_URL} == *.tgz ]]; then
    tar -xzvf ${SOURCE_FILE}
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