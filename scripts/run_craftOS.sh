#!/bin/bash

# Get the current working directory
current_dir=$(pwd)

# Run the craftos command with the --mount-ro option
craftos --mount-ro "/"="$current_dir"