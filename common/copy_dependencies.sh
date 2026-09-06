#!/bin/bash

# Function to copy the libraries recursively
copy_libraries() {
    echo "entering copy_libraries()" "$1"

    local lib_path="$1"
    local base_lib_path=$(basename "$lib_path")

    # Use otool to list linked libraries
    linked_libs=$(otool -L "$lib_path" | grep '@rpath' | awk '{print $1}')

    for lib in $linked_libs; do
    
        # Resolve the full path to the library
        lib_name=$(basename "$lib")
        echo "examining" $lib "in" $lib_path
        src_lib_path="/usr/local/lib/$lib_name"
        prefix_lib_path="$prefix_dir/$lib_name"
        dest_lib_path="$dest_dir/$lib_name"

        # Check if the library exists in /usr/local/lib
        if [ "$lib_name" != "$base_lib_path" ]; then

            # prioritize the prefix version first if it exists
            if [[ -f "$prefix_lib_path" ]]; then

                # Copy the (prefix) library to the input file's directory if not already there
                if [[ ! -f "$dest_lib_path" ]]; then
                    echo "Copying (1) $prefix_lib_path to $dest_dir"
                    copy_symlink_and_target "$prefix_lib_path" "$dest_dir"
                else
                    echo "Skipping (1) $prefix_lib_path since $dest_lib_path exists"
                fi
                
                # Recursively copy libraries linked to this library
                copy_libraries "$prefix_lib_path"                

            elif [[ -f "$src_lib_path" ]]; then

                # Copy the library to the input file's directory if not already there
                if [[ ! -f "$dest_lib_path" ]]; then
                    echo "Copying (2) $src_lib_path to $dest_dir"
                    copy_symlink_and_target "$src_lib_path" "$dest_dir"
                else
                    echo "Skipping (2) $src_lib_path since $dest_lib_path exists"
                fi
                
                # Recursively copy libraries linked to this library
                copy_libraries "$src_lib_path"
            fi
        fi
    done
}

copy_symlink_and_target() {
    echo "enter copy_symlink_and_target"

    symlink="$1"
    dest="$2"

    echo mkdir -p "$dest"
    mkdir -p "$dest"

    # Copy the symlink itself without resolving
    echo cp -P "$symlink" "$dest/"
    cp -P "$symlink" "$dest/"

    # Get the symlink target (can be relative)
    link_target=$(readlink "$symlink")

    # Resolve it to an absolute path
    symlink_dir=$(dirname "$symlink")
    absolute_target=$(realpath "$symlink_dir/$link_target")

    # Copy the target file
    if [[ -f $absolute_target ]]; then
        echo cp -R "$absolute_target" "$dest/"
        cp -R "$absolute_target" "$dest/"
    fi

    echo "exit copy_symlink_and_target"
}

# Main script execution
if [[ -z "$1" ]]; then
    echo "Usage: $0 <path_to_input_file>"
    exit 1
fi

input_file="$1"

export dest_dir="$(dirname "$input_file")"

if [ -n "$2" ]; then
    dest_dir="$2"
    mkdir -p $dest_dir
fi

export prefix_dir=""
if [ -n "$3" ]; then
    prefix_dir="$3lib"
fi

if [[ ! -f "$input_file" ]]; then
    echo "Error: $input_file does not exist."
    exit 1
fi

install_name_tool -add_rpath @executable_path/../Frameworks "$input_file"

# Start the recursive copying process from the input file
copy_libraries "$input_file"

echo "All libraries have been copied."