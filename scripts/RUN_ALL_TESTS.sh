#!/bin/bash

# Get the current working directory
current_dir=$(pwd)

# Get the ID argument (if any)
user_id=999

# Run the craftos command with the --mount-ro option and the --id flag
craftos --mount-ro "/"="$current_dir" --id $user_id --script "test/HEADLESS_RUN_TESTS.lua" --headless
