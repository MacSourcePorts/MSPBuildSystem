#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
export VK_ICD_FILENAMES="$DIR/../Resources/vulkan/icd.d/MoltenVK_icd.json"
exec "$DIR/Perimeter"