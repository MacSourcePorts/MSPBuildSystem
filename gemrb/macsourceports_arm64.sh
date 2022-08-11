# game/app specific values
export APP_VERSION="0.9.0"
export PRODUCT_NAME="gemrb"
export PROJECT_NAME="gemrb"
export PORT_NAME="GemRB"
export ICONSFILENAME="gemrb"
export EXECUTABLE_NAME="gemrb"
export PKGINFO="APPLGRB"
export GIT_TAG="v0.9.0"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

export ENTITLEMENTS_FILE="../MSPBuildSystem/gemrb/gemrb.entitlements"
export HIGH_RESOLUTION_CAPABLE="true"
export PRODUCT_BUNDLE_IDENTIFIER="org.gemrb.gemrb"
export ARCH_FOLDER="/arm64"
export ARCH_SUFFIX="-arm64"

cd ../../${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

# the latest release tag has issues on macOS that have since been fixed
# until the next release we'll just use the latest
git checkout tags/${GIT_TAG}

# fix glitch with 0.9.0's Info.plist template
cp ../MSPBuildSystem/gemrb/Info.plist platforms/apple/osx/Info.plist

rm -rf ${BUILT_PRODUCTS_DIR}
mkdir ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake, perform builds with make
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake  \
-DDISABLE_WERROR=1  \
-DCMAKE_OSX_ARCHITECTURES=arm64  \
-DCMAKE_BUILD_TYPE=Release  \
-DCMAKE_OSX_DEPLOYMENT_TARGET=10.12  \
-DCMAKE_PREFIX_PATH=/opt/Homebrew  \
-DCMAKE_INSTALL_PREFIX=/opt/Homebrew  \
-DPYTHON_LIBRARY=/opt/Homebrew/Frameworks/Python.framework/Versions/3.9/lib/libpython3.9.dylib  \
-DPYTHON_INCLUDE_DIR=/opt/Homebrew/Frameworks/Python.framework/Versions/3.9/include/python3.9  \
..
make
mv gemrb/${PRODUCT_NAME}.app ../release

cd ..

source ../MSPBuildSystem/common/signing_values.local

cp -a /opt/homebrew/opt/python@3.9/Frameworks/Python.framework release/gemrb.app/Contents/Frameworks
echo codesign --force timestamp --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/Current
codesign --force timestamp --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/Current

install_name_tool -change /opt/homebrew/opt/python@3.9/Frameworks/Python.framework/Versions/3.9/Python @executable_path/../Frameworks/Python.framework/Versions/3.9/Python release/gemrb.app/Contents/PlugIns/GUIScript.so

cp /opt/homebrew/opt/sdl2_mixer/lib/libSDL2_mixer-2.0.0.dylib release/gemrb.app/Contents/Frameworks
dylibbundler -od -b -x release/gemrb.app/Contents/Frameworks/libSDL2_mixer-2.0.0.dylib -d release/gemrb.app/Contents/MacOS/libs-arm64 -p @executable_path/libs-arm64/
install_name_tool -change /opt/homebrew/opt/sdl2_mixer/lib/libSDL2_mixer-2.0.0.dylib @executable_path/../Frameworks/libSDL2_mixer-2.0.0.dylib release/gemrb.app/Contents/PlugIns/SDLAudio.so

install_name_tool -change /opt/homebrew/opt/libvorbis/lib/libvorbisfile.3.dylib @executable_path/libs-arm64/libvorbisfile.3.dylib release/gemrb.app/Contents/PlugIns/OGGReader.so

cp /opt/homebrew/opt/libpng/lib/libpng16.16.dylib release/gemrb.app/Contents/MacOS/libs-arm64
install_name_tool -change /opt/homebrew/opt/libpng/lib/libpng16.16.dylib @executable_path/libs-arm64/libpng16.16.dylib release/gemrb.app/Contents/PlugIns/PNGImporter.so

cp /opt/homebrew/opt/freetype/lib/libfreetype.6.dylib release/gemrb.app/Contents/MacOS/libs-arm64
install_name_tool -change /opt/homebrew/opt/freetype/lib/libfreetype.6.dylib @executable_path/libs-arm64/libfreetype.6.dylib release/gemrb.app/Contents/PlugIns/TTFImporter.so
install_name_tool -change /opt/homebrew/opt/libpng/lib/libpng16.16.dylib @executable_path/libs-arm64/libpng16.16.dylib release/gemrb.app/Contents/MacOS/libs-arm64/libfreetype.6.dylib

# TODO: if this works figure out a better way
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/bin/python3.9
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_asyncio.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_bisect.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_blake2.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_bz2.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_codecs_cn.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_codecs_hk.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_codecs_iso2022.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_codecs_jp.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_codecs_kr.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_codecs_tw.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_contextvars.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_crypt.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_csv.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_ctypes_test.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_ctypes.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_curses_panel.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_curses.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_datetime.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_dbm.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_decimal.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_elementtree.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_gdbm.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_hashlib.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_heapq.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_json.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_lsprof.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_lzma.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_md5.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_multibytecodec.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_multiprocessing.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_opcode.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_pickle.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_posixshmem.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_posixsubprocess.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_queue.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_random.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_scproxy.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_sha1.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_sha256.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_sha3.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_sha512.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_socket.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_sqlite3.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_ssl.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_statistics.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_struct.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_testbuffer.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_testcapi.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_testimportmultiple.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_testinternalcapi.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_testmultiphase.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_uuid.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_xxsubinterpreters.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_xxtestfuzz.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/_zoneinfo.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/array.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/audioop.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/binascii.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/cmath.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/fcntl.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/grp.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/math.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/mmap.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/nis.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/parser.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/pyexpat.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/readline.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/resource.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/select.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/syslog.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/termios.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/unicodedata.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/xxlimited.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/lib/python3.9/lib-dynload/zlib.cpython-39-darwin.so
codesign --force --timestamp --options runtime --sign "${SIGNING_IDENTITY}" release/gemrb.app/Contents/Frameworks/Python.framework/Versions/3.9/Resources/Python.app/Contents/MacOS/Python

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1" entitlements

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"