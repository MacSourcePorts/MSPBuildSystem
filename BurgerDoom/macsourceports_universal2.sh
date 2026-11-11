# game/app specific values
export APP_VERSION="2.0.0"
export PRODUCT_NAME="BurgerDoom"
export PROJECT_NAME="BurgerDoom"
export PORT_NAME="BurgerDoom"
export ICONSFILENAME="BurgerDoom"
export EXECUTABLE_NAME="BurgerDoom"
export PKGINFO="APPLBGDM"

# constants
source ../common/constants.sh
export MINIMUM_SYSTEM_VERSION="10.15"

cd ../../${PROJECT_NAME}

if [ -n "$2" ]; then
	export APP_VERSION="${2/v/}"
	echo "Setting version to: $APP_VERSION"
else
	echo "Leaving version at : $APP_VERSION"
fi

# --- case-insensitive filesystem workarounds (remove once fixed upstream) ---
# 1. The 2.0.0 tag shipped doom.h/doomrez.h/states.h as 4-line shims that include
#    themselves; the real headers only arrived in the next commit ("fixing build").
#    That commit and everything after it carries both Doom.h (shim) and doom.h
#    (real), which collapse into one file on macOS. Either way, put the real
#    header on disk: take it from HEAD if HEAD has it, else from the fix commit.
HEADER_FIX_COMMIT="3d32c55772375868ded82d7aedf21830af9cd74b"
for f in doom.h doomrez.h sounds.h states.h; do
	if git cat-file -e "HEAD:source/$f" 2>/dev/null && ! git show "HEAD:source/$f" | grep -q DOOM3DO_CASE_; then
		src="HEAD"
	else
		src="${HEADER_FIX_COMMIT}"
	fi
	git show "${src}:source/$f" > "source/$f.real"
	mv -f "source/$f.real" "source/$f"
done
# 2. source/String.h is a shim for <string.h>, but with source/ on the include
#    path <string.h> resolves right back to it, so nothing from libc gets declared.
grep -rlE '#include [<"]String\.h[>"]' source | xargs sed -i '' -E 's/#include [<"]String\.h[>"]/#include <string.h>/'
rm -f source/String.h

# --- game data location (remove once upstream supports it) ---
# The game opens everything (REZFILE, PREZFILE, Sounds/, Music/, startup/,
# MAPNAMES.TXT, FINALE.TXT, DoomPrefs, saves) relative to the working directory,
# which is "/" when launched from Finder. We don't ship the data, so switch to
# ~/Library/Application Support/BurgerDoom at startup (created if missing) unless
# a REZFILE is already in the working directory, and tell the user where the data
# goes if it isn't there.
python3 - source/threedo.c <<'MSP_PATCH'
import sys
path = sys.argv[1]
src = open(path, encoding="latin-1", newline="").read()
if "MSP_DATA_DIR" in src:
    sys.exit(0)  # already patched

def insert(text, anchor, addition, before):
    if text.count(anchor) != 1:
        sys.exit("BurgerDoom data-dir patch: expected exactly one '%s' in %s" % (anchor, path))
    return text.replace(anchor, addition + anchor if before else anchor + addition)

src = insert(src, '#include <SDL3/SDL.h>\n', '''extern int chdir(const char *); /* not <unistd.h>: its close() clashes with the game's */
#define MSP_DATA_DIR "BurgerDoom"
static char gMspDataDir[4096] = ".";
''', before=False)

src = insert(src, '    snprintf(gRezFilePath, sizeof(gRezFilePath), "%s", "REZFILE");\n', '''    {
        FILE *mspProbe = fopen("REZFILE", "rb");
        if (mspProbe) {
            fclose(mspProbe);
        } else {
            char *mspDir = SDL_GetPrefPath(NULL, MSP_DATA_DIR);
            if (mspDir) {
                snprintf(gMspDataDir, sizeof(gMspDataDir), "%s", mspDir);
                if (chdir(mspDir) != 0)
                    fprintf(stderr, "DOOM3DO: could not switch to %s\\n", mspDir);
                SDL_free(mspDir);
            }
        }
    }
''', before=True)

src = insert(src, '        fprintf(stderr, "DOOM3DO: failed to open REZFILE in %s\\n", gRezFilePath);\n', '''        {
            char mspMsg[sizeof(gMspDataDir) + 256];
            snprintf(mspMsg, sizeof(mspMsg),
                "The game data was not found.\\n\\nCopy REZFILE and the other files that come with "
                "the Burger Doom release (Music, Sounds, startup, etc.) into:\\n\\n%s", gMspDataDir);
            SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "Burger Doom", mspMsg, NULL);
        }
''', before=False)

open(path, "w", encoding="latin-1", newline="").write(src)
print("BurgerDoom data-dir patch applied")
MSP_PATCH

rm -rf ${BUILT_PRODUCTS_DIR}

mkdir ${BUILT_PRODUCTS_DIR}
mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}
cd ${BUILT_PRODUCTS_DIR}
cmake \
-DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
..
cmake --build . --parallel $NCPU
# 2.0.0 builds its own DOOM3DO.app; pull the binary out into our bundle
cp DOOM3DO.app/Contents/MacOS/DOOM3DO ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME}
# the CRT shader is looked up via SDL_GetBasePath(), which is Contents/Resources in a bundle
mkdir -p ${UNLOCALIZED_RESOURCES_FOLDER_PATH}
if [ -f ../shaders/doom3do.spv ]; then
	cp ../shaders/doom3do.spv ${UNLOCALIZED_RESOURCES_FOLDER_PATH}
fi
"../../MSPBuildSystem/common/copy_dependencies.sh" ${EXECUTABLE_FOLDER_PATH}/${EXECUTABLE_NAME} ${FRAMEWORKS_FOLDER_PATH}

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh" "skiplipo"

# sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

# create dmg
"../MSPBuildSystem/common/package_dmg.sh"