#!/bin/bash

# Get the current working directory
current_dir=$(pwd)

# ID to put tests in
user_id=42069

# Run the craftos command with the --mount-ro option and the --id flag
craftos --mount-ro "/"="$current_dir" --id $user_id --script "test/RunAndReport.lua" --headless

# Open the report in a new browser window
firefox --new-window "$HOME/craftos-pc-save/computer/$user_id/test_report.html"