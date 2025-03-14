export SOURCE_URL="https://luarocks.org/releases/luarocks-3.11.1.tar.gz"
export CONFIGURE_ARGS="--prefix=/usr/local --with-lua=/usr/local --with-lua-include=/usr/local/include/lua"

source "../common/get_source.sh"
source "../common/make_build2.sh"

mkdir -p ~/.luarocks
LUACONFIG='variables = {
   CC = "clang",
   CFLAGS = "-arch x86_64 -arch arm64 -O2 -mmacosx-version-min=10.7",
   LDFLAGS = "-arch x86_64 -arch arm64 -mmacosx-version-min=10.7"
}
'
echo "${LUACONFIG}" > ~/.luarocks/config-5.4.lua

sudo luarocks install luafilesystem
sudo luarocks install lpeg
sudo luarocks install luasocket --from=http://luarocks.org/dev
sudo luarocks install luasec OPENSSL_DIR=/usr/local