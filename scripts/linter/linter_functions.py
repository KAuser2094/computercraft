import os
def read_file(file_path):
    """Read the contents of the file and return it."""
    if not os.path.isfile(file_path):
        raise FileNotFoundError(f"Error: File '{file_path}' does not exist.")
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.read()

def write_file(file_path, contents):
    """Write the contents to the file at the specified path."""
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(contents)

def strip_lines(contents):
    """Strips lines that contain only whitespace (spaces or tabs)."""
    return "\n".join(line.strip() for line in contents.splitlines())

def end_with_newline(contents):
    """Add a newline to the end of the contents if it doesn't already have one."""
    return contents if contents.endswith("\n") else contents + "\n"