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

    local path="$1"
    local dest="$2"

    echo mkdir -p "$dest"
    mkdir -p "$dest"

    # Copy every link in the chain without resolving it, then the file it
    # ends at. Libraries can be two links deep (libheif.dylib ->
    # libheif.1.dylib -> libheif.1.21.2.dylib); copying only the first link
    # and the file would leave the middle one missing and the first dangling.
    while [[ -L "$path" ]]; do
        echo cp -P "$path" "$dest/"
        cp -P "$path" "$dest/"

        # the link target can be relative to the link's folder
        local link_target=$(readlink "$path")
        if [[ "$link_target" != /* ]]; then
            link_target="$(dirname "$path")/$link_target"
        fi
        path="$link_target"
    done

    # Copy the target file
    if [[ -f "$path" ]]; then
        echo cp -R "$path" "$dest/"
        cp -R "$path" "$dest/"
    fi

    echo "exit copy_symlink_and_target"
}

# The rpaths in one architecture of a file pointing into /usr/local (or the
# prefix), one per line
local_rpaths() {
    local file="$1"
    local arch="$2"
    otool -arch "$arch" -l "$file" | grep -A2 'cmd LC_RPATH' | awk '$1 == "path" {print $2}' |
        while read -r rpath; do
            if [[ "$rpath" == /usr/local/* || ( -n "$prefix_dir" && "$rpath" == "$prefix_dir"* ) ]]; then
                echo "$rpath"
            fi
        done
}

# Remove rpaths into /usr/local from a file. Libraries built there (glib and
# the other meson-built ones, for example) carry one from their own builds,
# and on a Mac with libraries in /usr/local it would make the app load those
# instead of its own copies in Frameworks. Each architecture is checked on its
# own: a universal library can have the rpath in one and not the other, and
# install_name_tool -delete_rpath on the whole file fails unless all have it.
strip_local_rpaths() {
    local file="$1"
    local archs=$(lipo -archs "$file" 2>/dev/null)
    [[ -z "$archs" ]] && return

    local rpaths=$(for arch in $archs; do local_rpaths "$file" "$arch"; done | sort -u)
    for rpath in $rpaths; do
        # the same rpath can be listed more than once; each delete removes one
        local tries=0
        while true; do
            local with_rpath=""
            for arch in $archs; do
                if local_rpaths "$file" "$arch" | grep -qxF "$rpath"; then
                    with_rpath="$with_rpath $arch"
                fi
            done
            [[ -z "$with_rpath" ]] && break
            if (( ++tries > 10 )); then
                echo "Error: could not remove rpath $rpath from $file"
                exit 1
            fi

            chmod u+w "$file"
            echo "Removing rpath $rpath from $file (${with_rpath# })"
            if [[ "$(echo $with_rpath)" == "$(echo $archs)" ]]; then
                install_name_tool -delete_rpath "$rpath" "$file" 2>/dev/null
            else
                for arch in $with_rpath; do
                    lipo "$file" -thin "$arch" -output "$file.$arch"
                    install_name_tool -delete_rpath "$rpath" "$file.$arch" 2>/dev/null
                    lipo "$file" -replace "$arch" "$file.$arch" -output "$file"
                    rm "$file.$arch"
                done
            fi
        done
    done
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

# the app must load the libraries in its bundle, never the ones in /usr/local
strip_local_rpaths "$input_file"
for lib in "$dest_dir"/*.dylib; do
    [[ -f "$lib" && ! -L "$lib" ]] && strip_local_rpaths "$lib"
done

echo "All libraries have been copied."