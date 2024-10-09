export SOURCE_URL="https://downloads.sourceforge.net/project/giflib/giflib-5.2.2.tar.gz"
export CONFIGURE_ARGS=""

source "../common/get_source.sh"
gsed -i 's/CFLAGS  = -std=gnu99 -fPIC -Wall -Wno-format-truncation $(OFLAGS)/CFLAGS  = -std=gnu99 -fPIC -Wall -Wno-format-truncation $(OFLAGS) -arch arm64 -arch x86_64/g' source/giflib-5.2.2/Makefile 
source "../common/make_build.sh"