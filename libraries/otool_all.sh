#!/bin/bash

# Directory to scan
LIB_DIR="/usr/local/lib"

cd $LIB_DIR

# Find all .dylib files and process them if they are not symlinks
find . -name "*.dylib" | while read -r dylib; do
    # Check if the file is not a symlink
    if [ ! -L "$dylib" ]; then
        # echo "Processing: $dylib"
        otool -L -arch arm64 "$dylib"
    # else
        # echo "Skipping symlink: $dylib"
    fi
done