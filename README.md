# computercraft

This "init" branch holds a "template" (or whatever you wish to call it) that can be used for a cc tweaked repo.

## .vscode/

`.vscode/` directory holds `settings.json` with the `CC:Tweaked` addon for the lua language server added as well as other changes including:
- Hides any lua file in the code stub for the source code.
- ...

## Scripts

Includes helper scripts (usually in python).

### bundle_minify.py

Takes in a lua file (include the extension) amd then bundles up the code and minifies it. Resulting in a single line compact and (mostly) isolated file.

We include a `rom/` folder which is a stump to the source code so we can require from "cc" modules. 

Note that this will technically mean that parts of the code may fall under the CCPL License. (I don't understand Licenses, there is a copy of the CCPL License in the `rom/` folder)

### linter/

Holds linters that can be ran on a file to change it. Use a "RunOnSave" extension to pass in the file to the linter.

#### lua.py

Obviously for lua files, makes all comments have a leading sapce, removes trailing whitespace and all files are guarenteed to end in a newline.