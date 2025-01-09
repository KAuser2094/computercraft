import sys
import subprocess
import os

def main():
    if len(sys.argv) != 2:
        print("Usage: python bundle_minify.py <input_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    if not os.path.isfile(input_file):
        print(f"Error: {input_file} does not exist.")
        sys.exit(1)

    output_file = f"{os.path.splitext(input_file)[0]}_min.lua"

    try:
        # Run luabundler and check for errors
        bundler_process = subprocess.Popen(
            ["luabundler", 
             "bundle", 
             input_file, 
             "-p", 
             "./?.lua", # Root directory 
             "-p",
             "cc_tweaked_rom_stub/modules/main/?.lua", # + the modules from rom
             ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        bundler_output, bundler_error = bundler_process.communicate()

        if bundler_process.returncode != 0:
            print(f"Bundling failed: {bundler_error.decode()}")
            sys.exit(1)

        # Run luamin and check for errors
        minify_process = subprocess.Popen(
            ["luamin", "-c"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        minify_output, minify_error = minify_process.communicate(input=bundler_output)

        if minify_process.returncode != 0:
            print(f"Minification failed: {minify_error.decode()}")
            sys.exit(1)

        with open(output_file, "wb") as f:
            f.write(minify_output)

        print(f"Output written to {output_file}")

    except FileNotFoundError as e:
        print(f"Error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
