#!/bin/bash

# Directory to search for .dylib files
LIB_DIR="/usr/local/lib"

# Loop through all .dylib files in the directory (excluding symlinks and aliases)
find "$LIB_DIR" -type f -name "*.dylib" | while read -r dylib; do
    # echo "Processing $dylib..."
    
    # Get the current install name
    install_name=$(otool -D "$dylib" | tail -n 1)

    # echo "Install name for $dylib is: $install_name in LIB_DIR $LIB_DIR"
    
    # Extract the file name from the install name
    base_name=$(basename "$install_name")
    
    # Check if install name starts with /usr/local/lib or @rpath
    if [[ "$install_name" == "$LIB_DIR"* ]] || [[ "$install_name" == "$base_name" ]]; then
        # Set the new install name to @rpath/<file_name>
        new_install_name="@rpath/$base_name"
        
        echo "Changing install name from $install_name to $new_install_name..."
        
        # Update the install name using install_name_tool
        install_name_tool -id "$new_install_name" "$dylib"
    fi

    # Get all the shared libraries the .dylib file depends on
    otool -L "$dylib" | tail -n +2 | awk '{print $1}' | while read -r dependency; do
        dep_base_name=$(basename "$dependency")
        # Check if the dependency starts with /usr/local/lib or @rpath
        if [[ "$dependency" == "$LIB_DIR"* ]] || [[ "$dependency" == "$dep_base_name" ]]; then
            # Extract the file name from the dependency
            
            # Set the new dependency path to @rpath/<file_name>
            new_dependency="@rpath/$dep_base_name"
            
            echo "Changing dependency $dependency to $new_dependency..."
            
            # Update the dependency using install_name_tool
            install_name_tool -change "$dependency" "$new_dependency" "$dylib"
        fi
    done
    
    # echo "Finished processing $dylib."
    # echo "----------------------------------"
done