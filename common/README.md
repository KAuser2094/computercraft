# Common

Shared `common` files between apps/programs.

## Modules

### Logger.lua

Based off: https://gitlab.com/ralphgod3/cctutorials/-/blob/master/Modules/Logger.lua?ref_type=heads.

Always the user to log at different severities and with different tags. Is able to print effecitvely anything by using the "cc.pretty" module.

There is a global level of severity (default: `Verbose`) and you can tag a message to log on the verbosity of the tag, if it has not been set then it will default set that tag to the global level.

Levels (in order) are:
- None
- Temporary (This is what `NoTag` or `tag=""` is set to)
- Fatal
- Error
- Warning
- Info
- Debug
- Verbose

So, `None` < `Temporary` < `Fatal` < `Error` < `Warning` < `Info` < `Debug` < `Verbose`. And you will only log if the level you are logging at is below the level of the tag you are working in.

# Interfaces

These are a form of `Class` that allow for the checking of wellformed classes post initialisation. They will error if the check fails. They also define the public log that a class will have.

# Types

These are types and aliases that do not need an Interface implementation and/or would not have fit in an Interface. (or in the case of `Class`, it could not be as an interface would use `Class` itself)