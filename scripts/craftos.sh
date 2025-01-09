#!/bin/bash

# Get the current working directory
current_dir=$(pwd)

# Get the ID argument (if any)
user_id=$1

# Validate the ID: If the given ID is a valid integer and >= 0, use it. Otherwise, default to 0.
if [[ ! "$user_id" =~ ^[0-9]+$ ]]; then
    user_id=0
fi

# Print the current directory and ID
echo "Mounting to: $current_dir"
echo "Starting up ID: ${user_id}"

# Run the craftos command with the --mount-ro option and the --id flag
craftos --mount-ro "/"="$current_dir" --id $user_id
