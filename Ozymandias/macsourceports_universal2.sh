# game/app specific values
export APP_VERSION="1.7.0"
export PRODUCT_NAME="ozymandias"
export PROJECT_NAME="ozymandias"
export PORT_NAME="Ozymandias"
export ICONSFILENAME="ozymandias"
export EXECUTABLE_NAME="ozymandias"
export GIT_TAG="v1.7.0"
export GIT_DEFAULT_BRANCH="master"

#constants
source ../common/constants.sh

cd ../../${PROJECT_NAME}

# reset to the main branch
echo git checkout ${GIT_DEFAULT_BRANCH}
git checkout ${GIT_DEFAULT_BRANCH}

# fetch the latest 
echo git pull
git pull

# check out the latest release tag
# echo git checkout tags/${GIT_TAG}
# git checkout tags/${GIT_TAG}

rm -rf ${BUILT_PRODUCTS_DIR}

# create makefiles with cmake, perform builds with make
export CC=/usr/local/opt/llvm@15/bin/clang
export CXX=/usr/local/opt/llvm@15/bin/clang++
export CXXFLAGS=-stdlib=libc++
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$NCPU

cd ..
export CC=/opt/Homebrew/opt/llvm@15/bin/clang
export CXX=/opt/Homebrew/opt/llvm@15/bin/clang++
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$NCPU

cd ..

# create the app bundle
"../MSPBuildSystem/common/build_app_bundle.sh"

#sign and notarize
"../MSPBuildSystem/common/sign_and_notarize.sh" "$1"

#create dmg
"../MSPBuildSystem/common/package_dmg.sh"