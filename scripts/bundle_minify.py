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
        # Run luabundler and luamin using subprocess
        bundler_process = subprocess.Popen(
            ["luabundler", "bundle", input_file, "-p", "./?.lua"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        minify_process = subprocess.Popen(
            ["luamin", "-c"],
            stdin=bundler_process.stdout,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        bundler_process.stdout.close()  # Allow bundler_process to receive a SIGPIPE if minify_process exits
        minify_output, minify_error = minify_process.communicate()
        
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
