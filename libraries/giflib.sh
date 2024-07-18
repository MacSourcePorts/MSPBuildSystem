export SOURCE_URL="https://downloads.sourceforge.net/project/giflib/giflib-5.2.2.tar.gz"
export MAKE_ARGS=""

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

gsed -i 's/CFLAGS  = -std=gnu99 -fPIC -Wall -Wno-format-truncation $(OFLAGS)/CFLAGS  = -std=gnu99 -fPIC -Wall -Wno-format-truncation $(OFLAGS) -arch arm64 -arch x86_64/g' Makefile 

(make -j$NCPU)
sudo make install