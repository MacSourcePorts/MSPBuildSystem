export SOURCE_URL="http://www.lua.org/ftp/lua-5.4.6.tar.gz"

export MAKE_ARGS="macosx"
export INSTALL_TOP="/usr/local"
export RANLIB="/usr/bin/ranlib"
export AR="/usr/bin/ar"

source "../common/get_source.sh"

curl -JLO https://raw.githubusercontent.com/Homebrew/formula-patches/11c8360432f471f74a9b2d76e012e3b36f30b871/lua/lua-dylib.patch
mv lua-dylib.patch source
patch -d source/${SOURCE_FOLDER} < source/lua-dylib.patch

gsed -i "s|AR= ar rcu*|AR= /usr/bin/ar rcu|" source/lua-5.4.6/src/Makefile
gsed -i "s|RANLIB= ranlib*|RANLIB= /usr/bin/ranlib|" source/lua-5.4.6/src/Makefile
gsed -i "s|@OPT_LIB@*|@rpath|" source/lua-5.4.6/src/Makefile

# I shouldn't have to do this one but 
gsed -i "s|\$(MYCFLAGS)*|-DLUA_USE_MACOSX -arch x86_64 -arch arm64|" source/lua-5.4.6/src/Makefile
gsed -i "s|\$(MYLDFLAGS)*|-arch x86_64 -arch arm64|" source/lua-5.4.6/src/Makefile
gsed -i "s|-dynamiclib*|-dynamiclib -arch x86_64 -arch arm64|" source/lua-5.4.6/src/Makefile

source "../common/make_build.sh"