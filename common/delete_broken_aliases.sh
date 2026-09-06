#!/bin/bash

# Directory to start the search from, can be passed as the first argument
DIR=${1:-.}

# Function to check if a file is an invalid Finder alias
is_invalid_alias() {
    # Use AppleScript to check the alias
    osascript <<EOF
    try
        tell application "Finder"
            set theItem to POSIX file "$1" as alias
            return false
        end tell
    on error
        return true
    end try
EOF
}

# Recursive function to delete broken symlinks and invalid aliases
delete_invalid_links() {
    local path="$1"
    # Iterate over items in the directory
    find "$path" -type l | while IFS= read -r item; do
        # Check if it's an invalid symlink
        if [[ ! -e "$item" ]]; then
            echo "Deleting broken symlink: $item"
            rm "$item"
        fi
    done

    # Find potential aliases by looking for regular files that are actually aliases
    find "$path" -type f | while IFS= read -r item; do
        if is_invalid_alias "$item" | grep -q "true"; then
            echo "Deleting invalid alias: $item"
            rm "$item"
        fi
    done
}

# Run the function on the specified directory
delete_invalid_links "$DIR"