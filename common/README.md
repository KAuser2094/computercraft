# Common

Shared `common` files between apps/programs.

## Modules

Actual code modules, what else would it be?

Note that all code here presumes that this folder will be within the `root` of some lua package path.

### Logger.lua

Based off: https://gitlab.com/ralphgod3/cctutorials/-/blob/master/Modules/Logger.lua?ref_type=heads.

Allows the user to log at different severities and with different tags. Is able to print effecitvely anything by using the "cc.pretty" module.

There is a global level of severity (default: `Verbose`) and you can tag a message to log on the verbosity of the tag, if it has not been set then it will default set that tag to the global level.

In addition, tags will hold other settings, note that a tag's settings will be a snapshot of when the tag's settings is first retrieved or set. If global level changes later it will still reflect the old settings (or whatever changes to the tag setting itself was made)

Debug Levels (in order) are:
- None
- Temporary (This is what `NoTag` or `tag=""` is set to)
- Fatal
- Error
- Warning
- Info
- Debug
- Verbose

So, `None` < `Temporary` < `Fatal` < `Error` < `Warning` < `Info` < `Debug` < `Verbose`. And you will only log if the level you are logging at is below the level of the tag you are working in.

Also adds functions for `error`, `assert` and a custom `assertFunctionRuns` and `assertFunctionErrors` (all with Tag variants) that can be used in place to the default counterparts.

### Class

Allows for the creation of Class Definitions and Instances to do OOP programming. It could be considered over-engineered as it was made with the goal to be easily extensible with mixins and checking of invariants to make sure a class is valid. Through `mark`-ing keys and the use of hook functions.

Also allows for private variables and fields (named `proxy` in the code as that is the table both used to link an instance to its definition as well and hold the private variables)

- Class Instance (The actual instance the user can use, `public` marked keys will appear in the table itself)
- - Proxy (The `mt` for the instance, holds private (`proxy`) variables and filters access to below)
- - - Class Definition (Holds the fields and methods specific to a class)
- - - - Base Definition (Holds most of the fields and methods that any class will have)

### Expect (actually `expect` to match ccTweaked)

An extension/rewrite to ccTweaked's `expect` module. Uses the `Logger` module for better output and allows for more custom types and a "metamethod"-like interface for any custom typing to be added. (See `IExpect` to see what functions need to be implemented)

### Test

Has a `module` and `runner` class. `Module`s can be used to create tests and the `Runner` class can callect these test modules and run them all, outputing the result.

## Types

Holds non functional code to introduce types.