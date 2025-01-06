# computercraft

This "init" branch holds a "template" (or whatever you wish to call it) that can be used for a cc tweaked repo.

## .vscode/

`.vscode/` directory holds `settings.json` with the `CC:Tweaked` add on for the lua language server added (and likely other stuff as they come up for me).

## bundle_minify.sh

`bundle_minify.sh` is a script that simply uses `luabundler` and `luamin` to both bundle and minify a lua file passed as an argument from `<input>.lua` to `<input>_min.lua` in the cwd, like so:

```
$ ./bundle_minify.sh <lua file path>
```

(Note: Original intention was to easily drag and drop a file into a server without http enabled. obviously, can just be used to compress modules down or other stuff)