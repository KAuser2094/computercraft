#!/bin/bash

# Check if a file name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <input_file>"
  exit 1
fi

INPUT_FILE=$1
OUTPUT_FILE="${INPUT_FILE%.*}_min.lua"

# Bundle the Lua files and pipe the output to luamin for minification
luabundler bundle "$INPUT_FILE" -p "./?.lua" | luamin -c > "$OUTPUT_FILE"