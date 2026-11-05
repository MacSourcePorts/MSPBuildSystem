source "./source_urls.sh"

export SOURCE_URL=${LUA_URL}

export MAKE_ARGS="macosx"
export INSTALL_TOP="/usr/local"
export RANLIB="/usr/bin/ranlib"
export AR="/usr/bin/ar"

source "../common/get_source.sh"

curl -JLO https://raw.githubusercontent.com/Homebrew/formula-patches/11c8360432f471f74a9b2d76e012e3b36f30b871/lua/lua-dylib.patch
mv lua-dylib.patch source
patch -d source/${SOURCE_FOLDER} < source/lua-dylib.patch

gsed -i "s|AR= ar rcu*|AR= /usr/bin/ar rcu|" source/${SOURCE_FOLDER}/src/Makefile
gsed -i "s|RANLIB= ranlib*|RANLIB= /usr/bin/ranlib|" source/${SOURCE_FOLDER}/src/Makefile
gsed -i "s|@OPT_LIB@*|@rpath|" source/${SOURCE_FOLDER}/src/Makefile

# I shouldn't have to do this one but 
gsed -i "s|\$(MYCFLAGS)*|-DLUA_USE_MACOSX -arch x86_64 -arch arm64|" source/${SOURCE_FOLDER}/src/Makefile
gsed -i "s|\$(MYLDFLAGS)*|-arch x86_64 -arch arm64|" source/${SOURCE_FOLDER}/src/Makefile
gsed -i "s|-dynamiclib*|-dynamiclib -arch x86_64 -arch arm64|" source/${SOURCE_FOLDER}/src/Makefile

# Lua 5.5 hides internal (LUAI_FUNC) symbols on Mach-O, so luac can't link against
# liblua.dylib (luaU_dump, luaG_getfuncline etc.). Link it against the static lib instead.
gsed -i 's|^\$(LUAC_T): \$(LUAC_O) \$(LUA_DYLIB)|$(LUAC_T): $(LUAC_O) $(LUA_A)|' source/${SOURCE_FOLDER}/src/Makefile
gsed -i 's|\$(LUAC_O) \$(LUA_DYLIB) \$(LIBS)|$(LUAC_O) $(LUA_A) $(LIBS)|' source/${SOURCE_FOLDER}/src/Makefile

source "../common/make_build.sh"

sudo install_name_tool -add_rpath /usr/local/lib/. /usr/local/bin/lua
sudo install_name_tool -add_rpath /usr/local/lib/. /usr/local/bin/luac