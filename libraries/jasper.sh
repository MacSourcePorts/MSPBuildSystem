export SOURCE_URL="https://github.com/jasper-software/jasper/releases/download/version-4.2.4/jasper-4.2.4.tar.gz"
export CMAKE_ARGS="-DJAS_ENABLE_DOC=OFF -DGLUT_glut_LIBRARY=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks/GLUT.framework -DJAS_ENABLE_AUTOMATIC_DEPENDENCIES=false -DJAS_ENABLE_SHARED=ON"

source "../common/get_source.sh"
source "../common/cmake_build.sh"