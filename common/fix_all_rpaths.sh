#!/bin/bash

# Directory to search for libraries
LIB_DIR="/Users/tomkidd/Desktop/libs_mini"

# Loop through all .dylib files in the library directory
for lib in "$LIB_DIR"/*.dylib; do
    # Get the base name of the library (e.g., "libvorbisfile.3.3.8.dylib")
    lib_basename=$(basename "$lib")

    # Check if the file is a symlink
    if [ -L "$lib" ]; then
        echo "$lib_basename is a symlink; skipping setting the id."
    else
        echo "Processing id for $lib_basename"

        # Set the id of the library to use @rpath if it's not a symlink
        echo sudo install_name_tool -id "@rpath/$lib_basename" "$lib"
        sudo install_name_tool -id "@rpath/$lib_basename" "$lib"

        # Use otool to list dependencies and filter out system paths
        otool -L "$lib" | tail -n +2 | awk '{print $1}' | while read dep; do
            # Get the base name of the dependency
            dep_basename=$(basename "$dep")

            # Only process dependencies in /usr/local/lib or with no path
            if [[ "$dep" == "$LIB_DIR/"* || "$dep" == "$dep_basename" ]]; then
                # Change the dependency path to use @rpath
                echo sudo install_name_tool -change "$dep" "@rpath/$dep_basename" "$lib"
                sudo install_name_tool -change "$dep" "@rpath/$dep_basename" "$lib"
                echo "Changed dependency $dep to @rpath/$dep_basename in $lib_basename"
            fi
        done
    echo "Library $lib_basename processed."
    fi

done

echo "All libraries processed."