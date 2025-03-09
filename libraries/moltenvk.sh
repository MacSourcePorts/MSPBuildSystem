# Go to https://vulkan.lunarg.com/sdk/home and download the Mac installer
# https://sdk.lunarg.com/sdk/download/1.4.304.1/mac/vulkansdk-macos-1.4.304.1.zip
# In the future this can be automated with https://vulkan.lunarg.com/content/view/latest-sdk-version-api 

export VULKAN_SDK=/Users/tomkidd/VulkanSDK/1.4.304.1/macOS
export PATH="$VULKAN_SDK/bin:$PATH"
export DYLD_LIBRARY_PATH="$VULKAN_SDK/lib:$DYLD_LIBRARY_PATH"
export VK_ICD_FILENAMES="$VULKAN_SDK/share/vulkan/icd.d/MoltenVK_icd.json"
export VK_LAYER_PATH="$VULKAN_SDK/share/vulkan/explicit_layer.d"

rm -rf source
mkdir source
cd source
git clone --branch v1.2.9 https://github.com/KhronosGroup/MoltenVK.git
cd MoltenVK

./fetchDependencies

# cmake -B build -S MoltenVK \
#     -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DCMAKE_SYSTEM_NAME=Darwin \
#     -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0

# cmake --build build --config Release --parallel

xcodebuild -project ExternalDependencies.xcodeproj \
    -scheme "ExternalDependencies-macOS" \
    -configuration Release \
    -arch x86_64 -arch arm64 \
    build

xcodebuild -project MoltenVKPackaging.xcodeproj \
    -scheme "MoltenVK Package (macOS only)" \
    -configuration Release \
    -arch x86_64 -arch arm64 \
    build

lipo -info Package/Release/MoltenVK/dylib/macOS/libMoltenVK.dylib

sudo cp Package/Release/MoltenVK/dylib/macOS/libMoltenVK.dylib /usr/local/lib/
sudo mkdir /usr/local/include/MoltenVK
sudo cp -R MoltenVK/include/MoltenVK /usr/local/include/MoltenVK