#!/bin/bash

# Check if a specific .dylib file was provided as an argument
if [ -n "$1" ]; then
    # Use the provided argument as the library to process
    LIB_FILE="$1"
    if [ ! -f "$LIB_FILE" ]; then
        echo "File $LIB_FILE not found."
        exit 1
    fi
else
    echo "Please provide a .dylib file to process."
    exit 1
fi

# Get the directory and base name of the specified library file
LIB_DIR=$(dirname "$LIB_FILE")
lib_basename=$(basename "$LIB_FILE")

echo "Processing $lib_basename"

# Check if the specified file is a symlink
if [ -L "$LIB_FILE" ]; then
    echo "$lib_basename is a symlink; skipping setting the id."
else
    echo "Processing id for $lib_basename"

    # Set the id of the library to use @rpath if it's not a symlink
    echo sudo install_name_tool -id "@rpath/$lib_basename" "$LIB_FILE"
    # sudo install_name_tool -id "@rpath/$lib_basename" "$LIB_FILE"

    # Use otool to list dependencies and filter out system paths
    otool -L "$LIB_FILE" | tail -n +2 | awk '{print $1}' | while read dep; do
        # Get the base name of the dependency
        dep_basename=$(basename "$dep")

        # Only process dependencies in /usr/local/lib or with no path
        if [[ "$dep" == "$LIB_DIR/"* || "$dep" == "$dep_basename" ]]; then
            # Change the dependency path to use @rpath
            echo sudo install_name_tool -change "$dep" "@rpath/$dep_basename" "$LIB_FILE"
            # sudo install_name_tool -change "$dep" "@rpath/$dep_basename" "$LIB_FILE"
            echo "Changed dependency $dep to @rpath/$dep_basename in $lib_basename"
        fi
    done
    echo "Library $lib_basename processed."
fi


