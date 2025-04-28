#!/bin/bash

# Function to copy the libraries recursively
copy_libraries() {
    local lib_path="$1"
    local base_lib_path=$(basename "$lib_path")
    # local exe_dir="$(dirname "$lib_path")"

    # Use otool to list linked libraries
    linked_libs=$(otool -L "$lib_path" | grep '@rpath' | awk '{print $1}')

    # echo otool -L "$lib_path"
    # otool -L "$lib_path"
    # echo "linked_libs" $linked_libs

    for lib in $linked_libs; do
        # Resolve the full path to the library
        lib_name=$(basename "$lib")
        echo "examining" $lib "in" $lib_path
        src_lib_path="/usr/local/lib/$lib_name"
        dest_lib_path="$exe_dir/$lib_name"

        # Check if the library exists in /usr/local/lib
        if [ "$lib_name" != "$base_lib_path" ]; then
            if [[ -f "$src_lib_path" ]]; then
                # Copy the library to the executable's directory if not already there
                if [[ ! -f "$dest_lib_path" ]]; then
                    echo "Copying $src_lib_path to $dest_lib_path"
                    cp "$src_lib_path" "$dest_lib_path"
                else
                    echo "Skipping $src_lib_path since $dest_lib_path exists ?"
                fi
                
                # Recursively copy libraries linked to this library
                copy_libraries "$src_lib_path"
            fi
        fi
    done
}

# Main script execution
if [[ -z "$1" ]]; then
    echo "Usage: $0 <path_to_executable>"
    exit 1
fi

executable="$1"

export exe_dir="$(dirname "$executable")"
if [ -n "$2" ]; then
    exe_dir="$2"
fi
if [[ ! -f "$executable" ]]; then
    echo "Error: $executable does not exist."
    exit 1
fi

# Start the recursive copying process from the main executable
copy_libraries "$executable"

echo "All libraries have been copied."