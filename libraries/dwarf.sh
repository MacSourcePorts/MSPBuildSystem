export SOURCE_URL="https://github.com/davea42/libdwarf-code/releases/download/v2.2.0/libdwarf-2.2.0.tar.xz"
export SOURCE_FILE="libdwarf-2.2.0.tar.xz"

export CONFIGURE_ARGS="--enable-shared"

source "../common/get_source.sh"
source "../common/make_build.sh"

sudo install_name_tool -id @rpath/libdwarf.2.dylib /usr/local/lib/libdwarf.2.dylib