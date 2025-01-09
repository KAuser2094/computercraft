# Use RunOnSave extension to run (python3 < { workspacePath } + { pathToThisFile (ie scripts/linter/lua.py>) } > < { filePath } >) if the <file> extension is lua
import sys
import os
import re

script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(script_dir)

from linter_functions import read_file, write_file, strip_lines, end_with_newline

def ensure_leading_space(contents):
    """ Ensure that comments have a space after the "--(-*)" """
    excludePatterns = [
        "-",
        r"\[\[",
        r"\]\]"
    ]
    
    pattern = f"--(?!{'|'.join(excludePatterns)})"
    return re.sub(f'{pattern}([^\s])', r'-- \1', contents)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python ensure_leading_space.py <absolute_file_path>")
        sys.exit(1)

    file_path = sys.argv[1]
    
    try:
        # Read the file contents
        contents = read_file(file_path)

        # Remove whitespace-only lines
        contents = strip_lines(contents)

        # Format the comments to ensure leading spaces
        contents = ensure_leading_space(contents)

        # Add newline to the end if it doesn't exist
        contents = end_with_newline(contents)

        # Write the updated contents back to the file
        write_file(file_path, contents)

        print(f"Updated '{file_path}' successfully.")
    except Exception as e:
        print(e)
        sys.exit(1)
